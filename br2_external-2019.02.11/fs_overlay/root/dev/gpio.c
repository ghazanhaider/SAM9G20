#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include "gpio.h"

int main(void) {
    gpio_t gpio_out;
    bool value;


    /* Open GPIO B9 which is B (32) + 8 = 40 with output direction */
    if (gpio_open(&gpio_out, 72, GPIO_DIR_OUT) < 0) {
        fprintf(stderr, "gpio_open(): %s\n", gpio_errmsg(&gpio_out));
        exit(1);
    }


    /* Write output GPIO with !value */
    if (gpio_write(&gpio_out, !value) < 0) {
        fprintf(stderr, "gpio_write(): %s\n", gpio_errmsg(&gpio_out));
        exit(1);
    }

    gpio_close(&gpio_out);
    return 0;
}
