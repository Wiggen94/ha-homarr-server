FROM ghcr.io/ajnart/homarr:latest

RUN mkdir /app/public/icons
# Copy data for add-on
COPY run.sh /app/scripts/
RUN chmod a+x /app/scripts/run.sh

CMD [ "/app/scripts/run.sh" ]