set -ex

# PIP_UPLOAD_FOLDER should end in a slash. This is to handle it being empty
# (when uploading to e.g. whl/cpu/) and also to handle nightlies (when
# uploading to e.g. /whl/nightly/cpu)

if [[ -z "$PACKAGE_ROOT_DIR" ]]; then
    PACKAGE_ROOT_DIR="$(pwd)"
fi

# Upload for all CUDA/cpu versions if not given one to use
if [[ -z "$CUDA_VERSIONS" ]]; then
    CUDA_VERSIONS=('cpu' 'cu90' 'cu100')
fi

# Make sure the user specifically refers to an upload folder
if [[ -z "$PIP_UPLOAD_FOLDER" ]]; then
    echo 'The upload folder is not set. We refuse to upload.'
    echo 'Please set PIP_UPLOAD_FOLDER'
    exit 1
fi

export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_FOR_PYTORCH_BINARY_TMP_BUCKET_YF225"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_KEY_FOR_PYTORCH_BINARY_TMP_BUCKET_YF225"

for cuda_ver in "${CUDA_VERSIONS[@]}"; do
    s3_libtorch_dir="s3://pytorch-binary-tmp-yf225/libtorch/${PIP_UPLOAD_FOLDER}${cuda_ver}/"
    if [[ "$cuda_ver" == cpu ]]; then
        wheel_dir="${PACKAGE_ROOT_DIR}/wheelhousecpu/"
        libtorch_dir="${PACKAGE_ROOT_DIR}/libtorch_housecpu/"
    else
        wheel_dir="${PACKAGE_ROOT_DIR}/wheelhouse${cuda_ver:2:2}/"
        libtorch_dir="${PACKAGE_ROOT_DIR}/libtorch_house${cuda_ver:2:2}/"
    fi

    if [[ -d "$libtorch_dir" ]]; then
        echo "Uploading all of: $(ls $libtorch_dir) to $s3_libtorch_dir"
        ls "$libtorch_dir" | xargs -I {} aws s3 cp "$libtorch_dir"/{} "$s3_libtorch_dir" --acl public-read
    fi
done
