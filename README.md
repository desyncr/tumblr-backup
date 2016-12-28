# Tumblr Backup

As a V1, post data is being written to `${TUMBLR_URL}.json`.

## Install

1. `bundle install`

2. populate `.env`: 

    ```
    CONSUMER_KEY='{your-consumer-key}'
    CONSUMER_SECRET='{your-consumer-secret}'
    ENABLE_DOWNLOAD=true
    ```

## Usage

    `TUMBLR_URL=example.tumblr.com ruby ./tumblr.rb`

## Next Steps

- [x] download images locally
- [x] format posts photo urls to match local photo filenames
- [ ] prevent posts from being re-read each usage
- [ ] handle video/non-photo posts
