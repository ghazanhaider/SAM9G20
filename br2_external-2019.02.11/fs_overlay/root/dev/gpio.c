#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include "gpio.h"

int main(void) {
    gpio_t gpio_out;
    bool value=0;
    int x;


    if (gpio_open(&gpio_out, 73, GPIO_DIR_OUT) < 0) {
        fprintf(stderr, "gpio_open(): %s\n", gpio_errmsg(&gpio_out));
        exit(1);
    }


    for (x=0;x<10;x++) {
        if (gpio_write(&gpio_out, !value) < 0) {
            fprintf(stderr, "gpio_write(): %s\n", gpio_errmsg(&gpio_out));
            exit(1);
        }
        value = !value;
        sleep(1);
    }

    gpio_close(&gpio_out);
    return 0;
}
