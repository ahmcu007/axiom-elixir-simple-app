# Use the official Elixir image
FROM elixir:1.14-alpine

# Set environment variables for mix
ENV MIX_ENV=prod \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    AXIOM_API_TOKEN=""

# Install Hex and Rebar (build tools required by Elixir)
RUN mix local.hex --force && \
    mix local.rebar --force

# Install necessary build packages
RUN apk update && \
    apk add --no-cache build-base git

# Create a directory for the app
WORKDIR /app

# Copy the mix files and install dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

# Copy the entire application code
COPY . .

# Compile the application
RUN mix compile

# Run the application
CMD ["mix", "run", "--no-halt"]
