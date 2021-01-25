#!/bin/zsh
set -euo pipefail

echo "Deploying A Head Full of Wishes database"

source _cloudfront-distribution-id

# build site
bundle exec jekyll build --config _config.yml,_config_build.yml

# upload to s3
s3cmd sync --guess-mime-type --no-mime-magic --delete-removed --exclude '.sass-cache' --exclude 's3cfg*' --exclude 'database/*' _deploy/ s3://www.fullofwishes.co.uk/database/

# invalidate cloudfront
aws cloudfront create-invalidation --distribution-id $CDN_DISTRIBUTION_ID --paths "/*"


echo "A Head Full of Wishes database successfully deployed."