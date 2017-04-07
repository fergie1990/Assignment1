cli: cli.swift
	rm -f t.txt
	mkdir -p bin
	swiftc -o bin/cli cli.swift

echo: echo.swift
	mkdir -p bin
	swiftc -o bin/echo echo.swift

hello: main.swift
	mkdir -p bin
	swiftc -o bin/hello main.swift

clean:
	rm -rf bin
