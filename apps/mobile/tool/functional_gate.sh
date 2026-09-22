#!/usr/bin/env bash
set -euo pipefail

flutter test \
  test/architecture/component_first_test.dart \
  test/architecture/token_integrity_test.dart \
  test/modules/fazendas/functional_catalog_test.dart \
  test/modules/fazendas/functional_journey_engine_test.dart \
  test/modules/fazendas/screens/mapped_feature_screen_test.dart \
  test/modules/fazendas/screens/mapped_feature_wave_b_test.dart \
  test/modules/fazendas/screens/mapped_feature_wave_c_test.dart \
  test/modules/fazendas/screens/mapped_feature_wave_d_test.dart \
  test/router/access_policy_test.dart \
  test/router/app_router_test.dart \
  test/shell/prototype_session_store_test.dart \
  test/shell/pages/login_page_test.dart \
  test/shell/pages/perfil_config_page_test.dart
