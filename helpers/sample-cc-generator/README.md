# sample-cc-generator

## Usage

To generate csv data

```bash
go run main.go
```

Supported flags

```bash
 -count int
        Number of entries to generate. Defaults to 100 (default 100)
  -filename string
        Filename to write csv data. Defaults to data-${count}.csv
  -seed int
        Random seed for generator. Defaults to 1 (default 1)
```
