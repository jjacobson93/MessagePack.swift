FROM swiftdocker/swift:latest

COPY Sources /App/Sources
COPY Tests /App/Tests

COPY Package.swift /App/Package.swift

WORKDIR /App
CMD ["swift", "test"]