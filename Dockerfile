# Use a base image with Python 3.10 and necessary tools installed
FROM python:3.10-windowsservercore AS builder

# Set working directory
WORKDIR /pyfetcher

# Copy the Python script into the container
COPY . /pyfetcher/

# Install necessary tools for creating MSI
RUN apt-get update && apt-get install -y \
    zip

ENV DISPLAY=:0

RUN pip install --upgrade pip

# Install required dependencies
RUN pip install --no-cache-dir pyinstaller pywin32

# Convert .py file to .exe
RUN pyinstaller --onefile --name pyfetcher.exe main.py


# Create zip file containing .exe
RUN zip /pyfetcher/pyfetcher-v1.0.zip /pyfetcher/dist/pyfetcher.exe

# Set up a simple web server to serve the zip file
FROM python:3.10-windowsservercore AS final

# Set working directory
WORKDIR /pyfetcher

# Copy zip file from builder stage
COPY --from=builder /pyfetcher/pyfetcher-v1.0.zip /pyfetcher/

# Expose the port
EXPOSE 80

# Start a simple HTTP server to serve the zip file
CMD ["python", "-m", "http.server", "80"]
