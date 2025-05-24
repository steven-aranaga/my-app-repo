FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Set up working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application
COPY . .

# Create necessary directories
RUN mkdir -p /app/data /app/logs

# Expose port
EXPOSE 5000

# Run the application
CMD ["python", "main.py"]

