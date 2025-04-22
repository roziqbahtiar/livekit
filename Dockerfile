# Copyright 2023 LiveKit, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# Stage 1: Build binary dari source Go
FROM golang:1.24-alpine AS builder

ARG TARGETPLATFORM
ARG TARGETARCH
RUN echo building for "$TARGETPLATFORM"

WORKDIR /workspace

# Copy Go module info
COPY go.mod go.sum ./
RUN go mod download

# Copy source
COPY cmd/ cmd/
COPY pkg/ pkg/
COPY test/ test/
COPY tools/ tools/
COPY version/ version/

# Build livekit-server
RUN CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH go build -a -o livekit-server ./cmd/server

# Stage 2: Runtime ringan
FROM alpine

# Tambahkan binary hasil build
COPY --from=builder /workspace/livekit-server /livekit-server

# Tambahkan config file
COPY livekit.yaml /etc/livekit.yaml

# Expose port (opsional untuk dokumentasi, tidak wajib di Docker)
EXPOSE 7880 7881 3478/udp

# Jalankan livekit-server dengan config
ENTRYPOINT ["/livekit-server", "--config", "/livekit.yaml"]

