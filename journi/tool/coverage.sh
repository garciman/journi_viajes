#!/usr/bin/env bash
set -uo pipefail   # quitamos -e para no abortar antes de generar report

# 1) Tests + cobertura (capturando el exit code)
flutter test --coverage
TEST_EXIT=$?

# 2) (Opcional) filtra archivos generados
if command -v lcov >/dev/null 2>&1; then
  lcov --remove coverage/lcov.info '*/**/*.g.dart' -o coverage/filtered.info || true
  INPUT_FILE="coverage/filtered.info"
else
  INPUT_FILE="coverage/lcov.info"
fi

# 3) Genera HTML si está genhtml instalado
if command -v genhtml >/dev/null 2>&1; then
  genhtml "$INPUT_FILE" -o coverage/html --legend || true
  echo "➡️  Informe: coverage/html/index.html"
else
  echo "⚠️  genhtml no instalado; usa 'sudo apt-get install -y lcov'"
fi

# 4) Mensaje según estado de tests y salir con ese código
if [ $TEST_EXIT -ne 0 ]; then
  echo "❌ Tests fallaron (exit $TEST_EXIT) — coverage generado igualmente."
else
  echo "✅ Tests OK — coverage regenerado."
fi
exit $TEST_EXIT
