FROM elixir:1.7.3

WORKDIR /opt/app/

ADD build-and-run.sh ./

# Set exposed ports
EXPOSE 53

# main build and run script
