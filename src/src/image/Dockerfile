FROM python:3.13-alpine
WORKDIR /app
COPY app.pyc .
RUN pip3 install --no-cache-dir flask gunicorn && pip3 install --no-cache-dir pymysql gunicorn && apk add --no-cache curl && rm -rf /root/.cache/
EXPOSE 8080
CMD ["python3", "app.pyc"]