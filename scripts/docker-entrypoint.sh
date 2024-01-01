#!/bin/bash

declare -A MOUNTS
# main
MOUNTS["${ROOT}/models/checkpoints"]="/data/checkpoints"
MOUNTS["${ROOT}/models/clip"]="/data/clip"
MOUNTS["${ROOT}/models/clip_vision"]="/data/clip_vision"
MOUNTS["${ROOT}/models/configs"]="/data/configs"
MOUNTS["${ROOT}/models/controlnet"]="/data/controlnet"
MOUNTS["${ROOT}/models/diffusers"]="/data/diffusers"
MOUNTS["${ROOT}/models/embeddings"]="/data/embeddings"
MOUNTS["${ROOT}/models/gligen"]="/data/gligen"
MOUNTS["${ROOT}/models/hypernetworks"]="/data/hypernetworks"
MOUNTS["${ROOT}/models/loras"]="/data/loras"
MOUNTS["${ROOT}/models/style_models"]="/data/style_models"
MOUNTS["${ROOT}/models/unet"]="/data/unet"
MOUNTS["${ROOT}/models/upscale_models"]="/data/upscale_models"
MOUNTS["${ROOT}/models/vae"]="/data/vae"
MOUNTS["${ROOT}/models/vae_approx"]="/data/vae_approx"
MOUNTS["${ROOT}/custom_nodes"]="/data/custom_nodes"
MOUNTS["${ROOT}/workflows"]="/data/workflows"

for to_path in "${!MOUNTS[@]}"; do
  set -Eeuo pipefail
  from_path="${MOUNTS[${to_path}]}"
  rm -rf "${to_path}"
  if [ ! -f "$from_path" ]; then
    mkdir -vp "$from_path"
  fi
  mkdir -vp "$(dirname "${to_path}")"
  ln -sT "${from_path}" "${to_path}"
  echo Mounted $(basename "${from_path}")
done

# copy models
if [ ! -f "${ROOT}/models/checkpoints/svd_xt.safetensors" ]; then
  cp "/default_models/checkpoints/svd_xt.safetensors" "${ROOT}/models/checkpoints"
fi

# copy workflows
source_dir="/workflows"
files_to_copy=("$source_dir"/*)
for source_file in "${files_to_copy[@]}"; do
    file_name=$(basename "$source_file")
    target_file="${ROOT}/workflows/${file_name}"

    # 检查目标文件是否已经存在
    if [ -e "$target_file" ]; then
        echo "文件已存在: $target_file"
    else
        # 如果目标文件不存在，则执行拷贝操作
        cp "$source_file" "$target_file"
        echo "已拷贝文件: $source_file 到 $target_file"
    fi
done

# copy custom_nodes
custom_node_dir="${ROOT}/custom_nodes"
default_custom_node_dir="${ROOT}/default_custom_nodes"
update_file="${ROOT}/custom_nodes/update.ini"

if [ -d "$default_custom_node_dir" ]; then
    for subfolder in "$default_custom_node_dir"/*; do
        subfolder_name=$(basename "$subfolder")
        echo "$subfolder_name" >> "$update_file"
        # 检查custom_node目录是否存在相应的子文件夹
        if [ ! -d "$custom_node_dir/$subfolder_name" ]; then
            # 复制子文件夹到custom_node目录
            cp -r "$subfolder" "$custom_node_dir/"
            echo "已复制 $subfolder_name 到 $custom_node_dir 目录."
        else
            echo "$subfolder_name 子文件夹已存在于 $custom_node_dir 目录中."
        fi
    done
fi

chown 1001:1001 -R ${ROOT}/models /data &
# Print build date
BUILD_DATE=$(cat /build_date.txt)
echo "=== Image build date: $BUILD_DATE ===" 

exec "$@ ${CLI_ARGS}"
