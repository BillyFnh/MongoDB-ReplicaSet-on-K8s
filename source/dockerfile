FROM mongo:4.2.3
WORKDIR /root
ENV MONGODB_ID mongo-0

RUN apt update

COPY /startup-script-mongo /root

CMD ./startup-$MONGODB_ID.sh