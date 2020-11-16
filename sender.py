import argparse
from random import randrange
from time import sleep
from pythonosc import dispatcher, osc_server, osc_message_builder, udp_client



def send_reading(reading):
    packet = osc_message_builder.OscMessageBuilder(address="/distance")

    # adds distance reading to the OSC message
    packet.add_arg(reading, arg_type='f')

    # completes the OSC message
    packet = packet.build()

    # sends distance back to host
    client.send(packet)
    print("sending", "/distance", reading)


if __name__ == "__main__":
    # OSC variables
    piPort = 10001
    localIP = "127.0.0.1"

    # set up arguments for the dispatcher
    parser = argparse.ArgumentParser()
    parser.add_argument("--hostIp", type=str, default=localIP,
                        help="The IP address to send back to`")
    parser.add_argument("--hostPort", type=int, default=piPort,
                        help="The port to send back to")
    args = parser.parse_args()

    client = udp_client.UDPClient(args.hostIp, args.hostPort)

    while True:
        #ui = input()
        reading = randrange(0, 60)
        try:
            reading = float(ui)
        except:
            pass
            #if ui == 'q':
            #    break
            #else:
            #f    reading = 0
        send_reading(reading)
        sleep(1)
