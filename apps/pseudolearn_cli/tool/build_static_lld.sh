#!/usr/bin/env bash
set -euo pipefail

readonly llvm_version="23.1.5"
readonly source_sha256="fb50b1eac93ddeb3aa8dab4cfe324dff74f4a9c2bdee6160c9e36188f8d06a6e"
readonly source_url="https://github.com/llvm/llvm-project/releases/download/llvmorg-${llvm_version}/llvm-project-${llvm_version}.src.tar.xz"

if [[ $# -ne 3 ]]; then
  echo "usage: build_static_lld.sh <work-directory> <x86_64|arm64> <output-file>" >&2
  exit 2
fi

work_directory="$1"
architecture="$2"
output_file="$3"
archive="${work_directory}/llvm-project-${llvm_version}.src.tar.xz"
source_directory="${work_directory}/llvm-project-${llvm_version}.src"
build_directory="${work_directory}/build-${architecture}"

mkdir -p "${work_directory}"
if [[ ! -f "${archive}" ]]; then
  curl --fail --location --silent --show-error --output "${archive}" "${source_url}"
fi
echo "${source_sha256}  ${archive}" | shasum -a 256 --check --status
if [[ ! -d "${source_directory}" ]]; then
  tar -xf "${archive}" -C "${work_directory}"
fi

cmake -G Ninja -S "${source_directory}/llvm" -B "${build_directory}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER="$(xcrun --find clang)" \
  -DCMAKE_CXX_COMPILER="$(xcrun --find clang++)" \
  -DCMAKE_OSX_ARCHITECTURES="${architecture}" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
  -DLLVM_ENABLE_PROJECTS=lld \
  -DLLVM_TARGETS_TO_BUILD="X86;AArch64" \
  -DLLVM_ENABLE_ASSERTIONS=OFF \
  -DLLVM_ENABLE_ZLIB=OFF \
  -DLLVM_ENABLE_ZSTD=OFF \
  -DLLVM_ENABLE_LIBXML2=OFF \
  -DLLVM_ENABLE_LIBEDIT=OFF \
  -DLLVM_ENABLE_LIBPFM=OFF \
  -DLLVM_BUILD_LLVM_DYLIB=OFF \
  -DLLVM_LINK_LLVM_DYLIB=OFF \
  -DBUILD_SHARED_LIBS=OFF \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_BENCHMARKS=OFF \
  -DLLVM_INCLUDE_EXAMPLES=OFF \
  -DLLVM_INCLUDE_DOCS=OFF
ninja -C "${build_directory}" lld
cp "${build_directory}/bin/lld" "${output_file}"
strip -x "${output_file}"
otool -L "${output_file}"
shasum -a 256 "${output_file}"
