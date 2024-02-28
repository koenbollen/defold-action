# Defold Action

Build Defold projects for Windows, Linux and web.

> Work in progress: This is just an experiment for now.

## Workflow

(this example is a work in progress)
```yaml
jobs:
  defold:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        platform: [windows, linux, web]
    steps:
    - uses: actions/checkout@v4
    - uses: actions/cache@v4
      with:
        key: ${{matrix.platform}}-defold-cache
        path: .defold-cache
    - id: build
      uses: koenbollen/defold-action@main
      with:
        target-platform: ${{matrix.platform}}
        defold-channel: 'stable'
        # defold-version: '1.6.4' # Optional, overrides defold-channel
    - uses: actions/upload-artifact@v4
      with:
        name: mygame-${{matrix.platform}}-${{github.ref_name}}-${{github.sha}}
        path: ${{steps.build.outputs.build-path}}
        if-no-files-found: error
        overwrite: true
```




