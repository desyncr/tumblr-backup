# Tumblr Backup

As a V1, post data is being written to `${TUMBLR_URL}.json`.

## Install

1. Install dependencies

	bundle install

2. Configure access keys

	CONSUMER_KEY=[your-consumer-key]
	CONSUMER_SECRET=[your-consumer-secret]
	ENABLE_DOWNLOAD=true

  * You may copy `.env.example`.

## Usage

    `TUMBLR_URL=example.tumblr.com ./tumblr.rb`

## Next Steps

- [x] Download images locally
- [x] Format posts photo urls to match local photo filenames
- [ ] Prevent posts from being re-read each usage
- [ ] Handle video/non-photo posts
