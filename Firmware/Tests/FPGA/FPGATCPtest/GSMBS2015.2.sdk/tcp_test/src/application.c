/* FLOW PROJECT SIMPLE TCP TEST APPLICATION */
#include <stdio.h>
#include <string.h>

#include "lwip/err.h"
#include "lwip/tcp.h"
#ifdef __arm__
#include "xil_printf.h"
#endif


struct tcp_pcb *pcb;

int transfer_data() {
	uint16_t data[1900];
	tcp_write(pcb, data, sizeof(data)/ sizeof(*data),0); // send some data
	return 0;
}

void print_app_header()
{
	xil_printf("\n\r\n\r-----lwIP TCP client ------\n\r");
}

err_t  sent(void * arg, struct tcp_pcb * tpcb,
                              u16_t len)
{
return ERR_OK;
}

err_t tcp_connected(void *arg, struct tcp_pcb *tpcb, err_t err)
{
	char *string = "Helloooooo!";
	if (err != ERR_OK)
		printf("Error connecting to server");
	else
	{
		tcp_sent(pcb, sent); // set callback
		tcp_write(pcb, string, 8,0); // send some data
	}
	return ERR_OK;
}


int start_application()
{

	struct ip_addr ipaddr;
	err_t err;
	u16_t port = 1955;
	IP4_ADDR(&ipaddr,  192, 168,   3, 22);
	/* create new TCP PCB structure */
	pcb = tcp_new();
	if (!pcb) {
		xil_printf("Error creating PCB. Out of Memory\n\r");
		return -1;
	}

	/* we do not need any arguments to callback functions */
	tcp_arg(pcb, NULL);

	/* bind to specified @port */
	err = tcp_connect(pcb, &ipaddr, port, tcp_connected);

	if (err != ERR_OK) {
		xil_printf("Unable to bind to connect to server port %d: err = %d\n\r", port, err);
		return -2;
	}


	xil_printf("TCP client connected @ port %d\n\r", port);

	return 0;
}
