import { existsSync, mkdirSync, rmSync } from 'node:fs'
import { dirname, isAbsolute, resolve } from 'node:path'
import { spawnSync } from 'node:child_process'

const flutterVersion = '3.44.6'
const repoRoot = resolve(import.meta.dirname, '..')
const mobileRoot = resolve(repoRoot, 'apps/mobile')
const buildOutput = resolve(mobileRoot, 'build/site')
const expectedOutput = resolve(repoRoot, 'apps/mobile/build/site')
const sdkRoot = resolve(mobileRoot, `.flutter-sdk/${flutterVersion}`)
const cachedFlutter = resolve(
  sdkRoot,
  process.platform === 'win32' ? 'bin/flutter.bat' : 'bin/flutter',
)

function run(
  command,
  args,
  { capture = false, allowFailure = false, cwd = repoRoot, env = process.env } = {},
) {
  const options = {
    cwd,
    env,
    encoding: capture ? 'utf8' : undefined,
    stdio: capture ? 'pipe' : 'inherit',
  }
  const needsShell =
    process.platform === 'win32' && /\.(?:bat|cmd)$/i.test(command)
  const result = spawnSync(command, args, {
    ...options,
    shell: needsShell,
  })

  if (result.error != null && !allowFailure) throw result.error
  if (result.status !== 0 && !allowFailure) {
    throw new Error(`${command} ${args.join(' ')} falhou com código ${result.status}`)
  }
  return result
}

function gitEnvironmentForFlutter(command) {
  if (!isAbsolute(command)) return process.env

  const flutterRoot = resolve(dirname(command), '..')
  const env = { ...process.env }
  const configuredCount = Number.parseInt(env.GIT_CONFIG_COUNT ?? '0', 10)
  const configIndex = Number.isNaN(configuredCount) ? 0 : configuredCount

  env.GIT_CONFIG_COUNT = `${configIndex + 1}`
  env[`GIT_CONFIG_KEY_${configIndex}`] = 'safe.directory'
  env[`GIT_CONFIG_VALUE_${configIndex}`] = flutterRoot
  return env
}

function reportsRequiredVersion(command) {
  const result = run(command, ['--version'], {
    capture: true,
    allowFailure: true,
    env: gitEnvironmentForFlutter(command),
  })
  return result.status === 0 && `${result.stdout}\n${result.stderr}`.includes(`Flutter ${flutterVersion}`)
}

function resolveFlutter() {
  const explicit = process.env.FLUTTER_BIN
  if (explicit != null && explicit !== '') {
    if (!reportsRequiredVersion(explicit)) {
      throw new Error(`FLUTTER_BIN deve apontar para Flutter ${flutterVersion}: ${explicit}`)
    }
    return explicit
  }

  const systemCommand = process.platform === 'win32' ? 'flutter.bat' : 'flutter'
  if (reportsRequiredVersion(systemCommand)) return systemCommand

  if (!existsSync(cachedFlutter)) {
    console.log(`==> Baixando Flutter ${flutterVersion}…`)
    mkdirSync(dirname(sdkRoot), { recursive: true })
    run('git', [
      'clone',
      '--depth',
      '1',
      '--branch',
      flutterVersion,
      'https://github.com/flutter/flutter.git',
      sdkRoot,
    ])
  }
  if (!reportsRequiredVersion(cachedFlutter)) {
    throw new Error(`SDK em cache não corresponde ao Flutter ${flutterVersion}`)
  }
  return cachedFlutter
}

if (buildOutput !== expectedOutput || !buildOutput.endsWith(resolve('apps/mobile/build/site'))) {
  throw new Error(`Diretório de saída inesperado: ${buildOutput}`)
}

const flutter = resolveFlutter()
const flutterEnvironment = gitEnvironmentForFlutter(flutter)
rmSync(buildOutput, { recursive: true, force: true })

run(flutter, ['config', '--enable-web'], { cwd: mobileRoot, env: flutterEnvironment })
run(flutter, ['pub', 'get'], { cwd: mobileRoot, env: flutterEnvironment })

console.log('==> Buildando app Flutter em apps/mobile/build/site…')
run(flutter, ['build', 'web', '--release', '-o', buildOutput], {
  cwd: mobileRoot,
  env: flutterEnvironment,
})

console.log('==> Buildando Widgetbook em apps/mobile/build/site/storybook…')
run(
  flutter,
  [
    'build',
    'web',
    '--release',
    '-t',
    'lib/widgetbook_app.dart',
    '--base-href',
    '/storybook/',
    '-o',
    resolve(buildOutput, 'storybook'),
  ],
  { cwd: mobileRoot, env: flutterEnvironment },
)

console.log('==> Executando smoke tests do artefato combinado…')
run(process.execPath, [resolve(repoRoot, 'scripts/smoke-flutter-deploy.mjs')])
console.log('==> Pipeline Flutter concluída.')
