# Introduction
This project dockerizes the patch of [dangelzjj/TL_ComfyU](https://github.com:dangelzjj/TL_ComfyUI.git). It provides a convenient mode to supply the workflow along with its models and packages, etc.

# Usage
*This project currently supports Linux as the deployment platform. It will also work using WSL2.*

## command
docker run   -v d:/stable_diffusion/docker:/tlmodels -v d:/stable_diffusion/docker/test/data:/data   -d zhangp365/comfyui_svd_patch:v0.1

## docker hub address
https://hub.docker.com/repository/docker/zhangp365/comfyui_svd_patch/general 

## Pre-Requisites
- docker
- docker compose
- CUDA docker runtime

## Docker Compose
This is the recommended deployment method (it is the easiest and quickest way to manage folders and settings through updates and reinstalls). The recommend variant is `default` (it is an enhanced version of the vanilla application).


