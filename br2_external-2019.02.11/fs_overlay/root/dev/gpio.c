#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include "gpio.h"

int main(void) {
    gpio_t *gpio_in, *gpio_out;
    bool value=0;

/*    gpio_in = gpio_new(); */
    gpio_out = gpio_new();

    /* Open GPIO /dev/gpiochip1 line 9 with input direction */
/*    if (gpio_open(gpio_in, "/dev/gpiochip1", 9, GPIO_DIR_IN) < 0) {
        fprintf(stderr, "gpio_open(): %s\n", gpio_errmsg(gpio_in));
        exit(1);
    } */

    /* Open GPIO /dev/gpiochip0 line 12 with output direction */
    if (gpio_open(gpio_out, "/dev/gpiochip0", 12, GPIO_DIR_OUT) < 0) {
        fprintf(stderr, "gpio_open(): %s\n", gpio_errmsg(gpio_out));
        exit(1);
    }

    /* Read input GPIO into value */
/*    if (gpio_read(gpio_in, &value) < 0) {
        fprintf(stderr, "gpio_read(): %s\n", gpio_errmsg(gpio_in));
        exit(1);
    } */

    /* Write output GPIO with !value */
    if (gpio_write(gpio_out, !value) < 0) {
        fprintf(stderr, "gpio_write(): %s\n", gpio_errmsg(gpio_out));
        exit(1);
    }

/*    gpio_close(gpio_in); */
    gpio_close(gpio_out);

/*    gpio_free(gpio_in); */
    gpio_free(gpio_out);

    return 0;
}
