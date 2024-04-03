# Use a base image with Python 3.10 and necessary tools installed
FROM python:3.10 AS builder

# Set working directory
WORKDIR /pyfetcher

# Copy the Python script into the container
COPY . /pyfetcher/

# Install required dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Convert .py file to .exe
RUN pyinstaller --onefile main.py

# Install necessary tools for creating MSI
RUN apt-get update && apt-get install -y \
    wine \
    wget \
    unzip

# Download and install WiX Toolset
RUN wget https://github.com/wixtoolset/wix3/releases/download/wix3112rtm/wix311.exe && \
    wine wix311.exe

# Create .msi installer
RUN wine ~/.wine/drive_c/Program\ Files\ \(x86\)/WiX\ Toolset\ v3.11/bin/candle.exe /pyfetcher/your_script.wxs && \
    wine ~/.wine/drive_c/Program\ Files\ \(x86\)/WiX\ Toolset\ v3.11/bin/light.exe /pyfetcher/your_script.wixobj -o /pyfetcher/your_script.msi

# Create zip file containing .exe and .msi
RUN zip /pyfetcher/your_script.zip /pyfetcher/dist/your_script.exe /pyfetcher/your_script.msi

# Set up a simple web server to serve the zip file
FROM python:3.10 AS final

# Set working directory
WORKDIR /pyfetcher

# Copy zip file from builder stage
COPY --from=builder /pyfetcher/your_script.zip /pyfetcher/

# Expose the port
EXPOSE 80

# Start a simple HTTP server to serve the zip file
CMD ["python", "-m", "http.server", "80"]
