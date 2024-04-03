# Use a Windows base image
FROM python:3.9 AS builder

# Set working directory
WORKDIR /app

RUN apt-get update && \
        apt-get install -y \
        mingw-w64 \
        zip


# Copy the Python script into the container
COPY main.py /app/

RUN pip install --upgrade pip

# Install necessary dependencies
RUN pip install --no-cache-dir pyinstaller

# Convert .py file to .exe
RUN pyinstaller --onefile --name pyfetcher.exe main.py

# Create zip file containing .exe
RUN zip pyfetcher-v1.0.zip dist/pyfetcher.exe

# Set up a simple web server to serve the zip file
FROM python:3.9 AS final

# Set working directory
WORKDIR /app

# Copy zip file from builder stage
COPY --from=builder /app/pyfetcher-v1.0.zip /app/

# Expose the port
EXPOSE 8000

# Start a simple HTTP server to serve the zip file
CMD ["python", "-m", "http.server", "8000"]
