# Test Docker cache in GitHub Action

This repo used to test and understand <https://github.com/pnpm/pnpm/issues/6064>, the Docker cache issue in GitHub Action

Attempts:

1. PR: <https://github.com/CallMeLaNN/test-docker-cache-in-action/pull/1>:

   - The [first action](https://github.com/CallMeLaNN/test-docker-cache-in-action/actions/runs/5314463587) cache for the first time
   - The [second action](https://github.com/CallMeLaNN/test-docker-cache-in-action/actions/runs/5314507409) doesn't use the cache as expected. Unlike in local `docker build` the `RUN --mount=type=cache` doesn't load the cache. Packages are downloaded again instead of reused. See this log:

     ```log
       Progress: resolved 111, reused 0, downloaded 111, added 111, done
     ```
