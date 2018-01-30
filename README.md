# EnvInfo

[![Build Status](https://travis-ci.org/tkf/EnvInfo.jl.svg?branch=master)](https://travis-ci.org/tkf/EnvInfo.jl)
[![Coverage Status](https://coveralls.io/repos/tkf/EnvInfo.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/tkf/EnvInfo.jl?branch=master)
[![codecov.io](http://codecov.io/github/tkf/EnvInfo.jl/coverage.svg?branch=master)](http://codecov.io/github/tkf/EnvInfo.jl?branch=master)


- `EnvInfo.status`: Get version number, Git revision and Git status of
  packages.  It's `Pkg.installed` + Git information.

- `EnvInfo.save`: Dump `EnvInfo.status` to a JSON file.
