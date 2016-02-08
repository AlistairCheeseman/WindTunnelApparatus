#include <stdio.h>
#include <string.h>

#include "lwip/err.h"
#include "lwip/udp.h"
#ifdef __arm__
#include "xil_printf.h"
#endif
struct udp_pcb *pcb;

int transfer_data() {
	uint8_t data[1700];
	struct pbuf *p;
	p =  pbuf_alloc(PBUF_TRANSPORT,sizeof(data),PBUF_RAM);
	memcpy(p->payload, data, sizeof(data)/sizeof(*data));
	udp_send(pcb,p);
	pbuf_free(p);
	return 0;
}

void print_app_header()
{
	xil_printf("\n\r\n\r-----lwIP UDP Speed Test ------\n\r");
}

int start_application()
{
	struct ip_addr ipaddr;
	err_t err;
	u16_t port = 1955;
	IP4_ADDR(&ipaddr,  192, 168,   3, 22);

	/* create new TCP PCB structure */
	pcb = udp_new();
	if (!pcb) {
		xil_printf("Error creating PCB. Out of Memory\n\r");
		return -1;
	}

	/* bind to specified @port */
	err = udp_connect(pcb, &ipaddr, port);
	if (err != ERR_OK) {
		xil_printf("Unable to bind to port %d: err = %d\n\r", port, err);
		return -2;
	}

	xil_printf("UDP begun @ port %d\n\r", port);

	return 0;
}
