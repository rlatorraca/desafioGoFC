##### Stage 1 #####

### Use golang:1.20 as base image for building the application
FROM golang:1.20 as builder


### Create new directly and set it as working directory
RUN mkdir -p /app
WORKDIR /app

# pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change
COPY go.mod .
COPY hello.go .

### Setting a proxy for downloading modules
ENV GOPROXY https://proxy.golang.org,direct

RUN go mod download && go mod verify

COPY . .

### CGO has to be disabled cross platform builds
### Otherwise the application won't be able to start
ENV CGO_ENABLED=0

### Build the Go app for a linux OS
### 'scratch' and 'alpine' both are Linux distributions
RUN GOOS=linux go build ./hello.go

#RUN go build -v -o /usr/local/bin/app ./...



##### Stage 2 #####

### Define the running image
FROM scratch

### Set working directory
WORKDIR /app

### Copy built binary application from 'builder' image
COPY --from=builder /app/hello .

### Run the binary application
CMD ["/app/hello"]