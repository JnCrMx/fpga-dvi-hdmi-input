#include <stdio.h>

#include "dvi_in.h"
#include "irq_ctrl.h"
#include "edid.h"

void pretty_print(unsigned int fb, unsigned int x_step, unsigned int y_step) {
    framebuffers_status_t status;
    dvi_get_framebuffers_status(&status);

    framebuffers_control_t ctrl;
    dvi_get_framebuffers_control(&ctrl);
    status.width /= (ctrl.skip_column+1);
    status.height /= (ctrl.skip_row+1);

    // x_step /= (ctrl.skip_column+1);
    // y_step /= (ctrl.skip_row+1);

    int last_r = -1;
    int last_g = -1;
    int last_b = -1;
    for(unsigned int y=0; y<status.height-y_step+1; y+=y_step) {
        for(unsigned int x=0; x<status.width-x_step+1; x+=x_step) {
            uint32_t avg_r = 0;
            uint32_t avg_g = 0;
            uint32_t avg_b = 0;
            for(unsigned int ly = 0; ly < y_step; ly++) {
                for(unsigned int lx = 0; lx < x_step; lx++) {
                    pixel_t pixel = dvi_get_framebuffer_pixel(&status, fb, x+lx, y+ly);
                    avg_r += pixel.red;
                    avg_g += pixel.green;
                    avg_b += pixel.blue;
                }
            }
            uint32_t r = avg_r / (x_step*y_step);
            uint32_t g = avg_g / (x_step*y_step);
            uint32_t b = avg_b / (x_step*y_step);
            if(r == last_r && g == last_g && b == last_b) {
                printf(" ");
            } else {
                printf("\x1B[48;2;%d;%d;%dm ", r, g, b);
                last_r = r;
                last_g = g;
                last_b = b;
            }
        }
        printf("\x1B[0m");
        printf("\n");
        last_r = -1;
        last_g = -1;
        last_b = -1;
    }
    printf("\x1B[0m");
}

void configure_edid() {
    printf(
        "Select EDID:\n"
        "1) 640x480 (DVI)\n"
        "2) 640x480 (HDMI)\n"
        "3) 800x600 (DVI)\n"
        "4) 800x600 (HDMI)\n"
        "5) 1024x768 (DVI)\n"
        "6) 1024x768 (HDMI)\n"
        "7) 1280x720 (DVI)\n"
        "8) 1280x720 (HDMI)\n"
        "9) 1920x1080 (DVI)\n"
        "0) 1920x1080 (HDMI)\n"
    );
    int edid_selection = fgetc(stdin);
    switch(edid_selection) {
        case '1':
            dvi_write_edid(edid_dvi_640x480, sizeof(edid_dvi_640x480));
            printf("Using 640x480 (DVI).\n");
            break;
        case '2':
            dvi_write_edid(edid_hdmi_640x480, sizeof(edid_hdmi_640x480));
            printf("Using 640x480 (HDMI).\n");
            break;
        case '3':
            dvi_write_edid(edid_dvi_800x600, sizeof(edid_dvi_800x600));
            printf("Using 800x600 (DVI).\n");
            break;
        case '4':
            dvi_write_edid(edid_hdmi_800x600, sizeof(edid_hdmi_800x600));
            printf("Using 800x600 (HDMI).\n");
            break;
        case '5':
            dvi_write_edid(edid_dvi_1024x768, sizeof(edid_dvi_1024x768));
            printf("Using 1024x76 (DVI).\n");
            break;
        case '6':
            dvi_write_edid(edid_hdmi_1024x768, sizeof(edid_hdmi_1024x768));
            printf("Using 1024x76 (HDMI).\n");
            break;
        case '7':
            dvi_write_edid(edid_dvi_1280x720, sizeof(edid_dvi_1280x720));
            printf("Using 1280x720 (DVI).\n");
            break;
        case '8':
            dvi_write_edid(edid_hdmi_1280x720, sizeof(edid_hdmi_1280x720));
            printf("Using 1280x720 (HDMI).\n");
            break;
        case '9':
            dvi_write_edid(edid_dvi_1920x1080, sizeof(edid_dvi_1920x1080));
            printf("Using 1920x1080 (DVI).\n");
            break;
        case '0':
            dvi_write_edid(edid_hdmi_1920x1080, sizeof(edid_hdmi_1920x1080));
            printf("Using 1920x1080 (HDMI).\n");
            break;
        default:
            printf("Invalid selection! Falling back to 640x480 (DVI).\n");
            dvi_write_edid(edid_dvi_640x480, sizeof(edid_dvi_640x480));
            break;
    }
}

unsigned int print_framebuffer_interrupts = 0;
void dvi_framebuffer_ready_handler() {
    uint32_t irq_no = irq_ctrl_get_irq_no();
    framebuffers_status_t status;
    dvi_get_framebuffers_status(&status);
    if(print_framebuffer_interrupts) {
        printf("=== IRQ %d: framebuffers status ===\n", irq_no);
        printf(
            "valid_frames = %d\n"
            "width = %d\n"
            "height = %d\n"
            "format = %x\n",
            status.valid_frames, status.width, status.height, status.format);
    }
}

void dvi_pll_locked_handler() {
    uint32_t irq_no = irq_ctrl_get_irq_no();
    clock_status_t status;
    dvi_get_clock_status(&status);

    printf("=== IRQ %d: PLL locked! ===\n", irq_no);
}
void dvi_pll_lost_handler() {
    uint32_t irq_no = irq_ctrl_get_irq_no();
    clock_status_t status;
    dvi_get_clock_status(&status);

    printf("=== IRQ %d: PLL lost! ===\n", irq_no);
}

int main(void) {
    printf("Hello!\n
            Type '?' for help.\n");

    print_framebuffer_interrupts = 0;
    irq_init_jump_table();
    irq_ctrl_allow_interrupt(2);
    irq_ctrl_set(2, &dvi_framebuffer_ready_handler);
    irq_ctrl_allow_interrupt(3);
    irq_ctrl_set(3, &dvi_framebuffer_ready_handler);
    irq_ctrl_allow_interrupt(4);
    irq_ctrl_set(4, &dvi_pll_locked_handler);
    irq_ctrl_allow_interrupt(5);
    irq_ctrl_set(5, &dvi_pll_lost_handler);
    irq_ctrl_enable_interrupts();
    irq_enable((1<<IRQ_EXTERNAL));

    // test reading framebuffer
    uint8_t* ptr = dvi_get_framebuffer(0);
    for(unsigned int i=0; i<1; i++) {
        uint32_t x = ptr[i];
        printf("%04x %04x ", x & 0xffff, x >> 16);
    }

    configure_edid();

    unsigned int max_quality[3] = {0, 0, 0};
    int last_deskew_error = 0;

    channel_deskew_debug_ctrl_t deskew_ctrl;
    deskew_ctrl.ovr = 0;
    deskew_ctrl.offset_r = 0;
    deskew_ctrl.offset_g = 0;
    deskew_ctrl.offset_b = 0;
    dvi_set_channel_deskew_debug_ctrl(&deskew_ctrl);

    pixel_counter_debug_ctrl_t pixel_counter_ctrl;
    pixel_counter_ctrl.ovr = 0;
    pixel_counter_ctrl.is_hdmi = 0;
    pixel_counter_ctrl.vsync_polarity = 0;
    pixel_counter_ctrl.hsync_polarity = 0;
    dvi_set_pixel_counter_debug_ctrl(&pixel_counter_ctrl);

    const unsigned int x_step_base = 1;
    const unsigned int y_step_base = 2;
    unsigned int step_factor = 5;
    for (;;)
    {
        clock_status_t clock_status;
        dvi_get_clock_status(&clock_status);
        printf(
            "=== clock status ===\n"
            "locked = %d\n"
            "pclk_counter = %u\n"
            "sys_clk_counter = %u\n",
            clock_status.locked, clock_status.pclk_counter, clock_status.sys_clk_counter);
        for (int i = 0;; i++)
        {
            dvi_get_clock_status(&clock_status);
            if (clock_status.locked)
            { // wait for locked clock
                break;
            }
        }

        {
            printf("=== calculating input frequency ===\n");

            clock_status_t clock_status1;
            dvi_get_clock_status(&clock_status1);

            for (int i = 0; i < 100; i++) { __asm__ __volatile__(""); }

            clock_status_t clock_status2;
            dvi_get_clock_status(&clock_status2);

            int sys_clk_delta = clock_status2.sys_clk_counter - clock_status1.sys_clk_counter;
            int pclk_delta = clock_status2.pclk_counter - clock_status1.pclk_counter;
            printf("sys_clk_delta = %d\n", sys_clk_delta);
            printf("pclk_delta = %d\n", pclk_delta);

            int factor = (1000 * pclk_delta) / sys_clk_delta;
            int freq = 50 * factor;
            printf("The pclk runs %d milli-times faster than the sys_clk and thus has a frequency of %d kHz\n", factor, freq);
        }

        pipeline_debug_t debug[3];
        dvi_get_pipeline_debug(debug);
        for (int c = 0; c < 3; c++)
        {
            max_quality[c] = debug[c].quality > max_quality[c] ? debug[c].quality : max_quality[c];
            printf(
                "=== pipeline debug[%d] ===\n"
                "valid = %d\n"
                "delay = %d\n"
                "quality = %d / %d\n"
                "last_valid = %03x\n"
                "last_invalid = %03x\n",
                c, debug[c].valid, debug[c].delay, debug[c].quality, max_quality[c],
                debug[c].last_valid, debug[c].last_invalid);
        }

        channel_deskew_debug_t deskew;
        dvi_get_channel_deskew_debug(&deskew);
        printf("=== channel deskew ===\n");
        printf(
            "offset_r = %d\n"
            "offset_g = %d\n"
            "offset_b = %d\n"
            "de = %d%d%d\n"
            "error_count = %d (%#d)\n",
            deskew.offset_r, deskew.offset_g, deskew.offset_b,
            (deskew.de & 0b1) != 0, (deskew.de & 0b10) != 0, (deskew.de & 0b100) != 0,
            deskew.error_count, deskew.error_count - last_deskew_error);
        last_deskew_error = deskew.error_count;

        pixel_t pixel1, pixel2;
        pixel_counter_debug_t pixel_counter;
        dvi_get_pixel_counter_debug(&pixel_counter);
        dvi_get_pipeline_debug_pixel(&pixel1);
        dvi_get_debug_pixel(&pixel2);
        printf("=== Pixel @ %u,%u (is_video_data = %d, is_hdmi = %d, guessed_polarity = %d) ===\n",
            pixel_counter.cx, pixel_counter.cy, pixel_counter.is_video_data,
            pixel_counter.is_hdmi, pixel_counter.guessed_polarity);
        printf("pipeline_debug_pixel = %02x%02x%02x\n", pixel1.red, pixel1.green, pixel1.blue);
        printf("         debug_pixel = %02x%02x%02x\n", pixel2.red, pixel2.green, pixel2.blue);

        {
            framebuffers_status_t status;
            dvi_get_framebuffers_status(&status);
            printf("=== framebuffers status ===\n");
            printf(
                "valid_frames = %d\n"
                "width = %d\n"
                "height = %d\n"
                "format = %x\n",
                status.valid_frames, status.width, status.height, status.format);

            uint8_t* ptr = (uint8_t*) dvi_get_framebuffer(0);
            for(unsigned int y = 0; y < 10; y++) {
                for(unsigned int x = 0; x < 5; x++) {
                    uint8_t v = ptr[y * status.width + x];
                    printf("%02x ", v);
                }
                printf("...");
                for(unsigned int x = status.width-5; x < status.width; x++) {
                    uint8_t v = ptr[y * status.width + x];
                    printf(" %02x", v);
                }
                printf("\n");
            }
        }

        while(1) {
            //break;

            printf("> ");
            int c = fgetc(stdin);
            printf("\n");
            if(c == 'c' || c == '\r') {
                break;
            } else if(c == 'd') {
                unsigned int fb = dvi_framebuffer_auto_lock();

                framebuffers_status_t status;
                framebuffers_control_t ctrl;
                dvi_get_framebuffers_status(&status);
                dvi_get_framebuffers_control(&ctrl);

                unsigned int total_pixels = status.width * status.height / ((ctrl.skip_row+1)*(ctrl.skip_column+1));
                unsigned int pixel_size = 1;
                unsigned int pixels_per_word = sizeof(uint32_t) / pixel_size;

                uint32_t* ptr = (uint32_t*) dvi_get_framebuffer(0);
                for(unsigned int i=0; i<total_pixels/pixels_per_word; i++) {
                    uint32_t x = ptr[i];
                    // uint8_t r = x & 0b11100000;
                    // uint8_t g = (x & 0b00011100) << 3;
                    // uint8_t b = (x & 0b00000011) << 6;
                    // printf("%02x%02x%02x", r, g, b);
                    x = ( ((x & 0xFF000000) >> 24) | ((x & 0x00FF0000) >> 8) | ((x & 0x0000FF00) << 8) | ((x & 0x000000FF) << 24) );
                    printf("%08x", x);
                }

                dvi_framebuffer_unlock(fb);
            } else if(c == 'p') {
                unsigned int fb = dvi_framebuffer_auto_lock();

                framebuffers_status_t status;
                dvi_get_framebuffers_status(&status);

                printf("Using framebuffer %d\n", fb);
                printf("=== framebuffers status ===\n");
                printf(
                    "valid_frames = %d\n"
                    "width = %d\n"
                    "height = %d\n"
                    "format = %x\n",
                    status.valid_frames, status.width, status.height, status.format);

                printf("\n");

                pretty_print(fb, x_step_base*step_factor, y_step_base*step_factor);

                dvi_framebuffer_unlock(fb);
            } else if(c == 'P') {
                unsigned int fb = dvi_framebuffer_auto_lock();
                printf("\033[2J");
                for(;;) {
                    dvi_framebuffer_lock(fb);
                    dvi_framebuffer_wait_valid(fb);

                    printf("\033[0;0H");
                    printf("Using framebuffer %d\n", fb);
                    pretty_print(fb, x_step_base*step_factor, y_step_base*step_factor);

                    dvi_framebuffer_unlock(fb);
                    fb = !fb;
                }
            } else if(c == 's') {
                printf("Trying to find good skew values...\n");
                channel_deskew_debug_ctrl_t deskew_ctrl;
                deskew_ctrl.ovr = 1;
                deskew_ctrl.offset_r = 0;
                deskew_ctrl.offset_g = 0;
                deskew_ctrl.offset_b = 0;
                dvi_set_channel_deskew_debug_ctrl(&deskew_ctrl);

                channel_deskew_debug_ctrl_t min_error;
                min_error.ovr = 1;
                uint32_t smallest_error = UINT32_MAX;

                for(int r=0; r<3; r++) {
                    for(int g=0; g<3; g++) {
                        for(int b=0; b<3; b++) {
                            deskew_ctrl.offset_r = r;
                            deskew_ctrl.offset_g = g;
                            deskew_ctrl.offset_b = b;
                            dvi_set_channel_deskew_debug_ctrl(&deskew_ctrl);

                            channel_deskew_debug_t deskew1, deskew2;
                            dvi_get_channel_deskew_debug(&deskew1);
                            for (int i = 0; i < 100000; i++) { __asm__ __volatile__(""); }
                            dvi_get_channel_deskew_debug(&deskew2);
                            uint32_t error = deskew2.error_count - deskew1.error_count;
                            printf("%d%d%d => %d errors\n", r, g, b, error);

                            if(error < smallest_error) {
                                min_error.offset_r = r;
                                min_error.offset_g = g;
                                min_error.offset_b = b;
                                smallest_error = error;
                            }
                        }
                    }
                }

                printf("Selecting deskew %d%d%d\n", min_error.offset_r, min_error.offset_g, min_error.offset_b);
                dvi_set_channel_deskew_debug_ctrl(&min_error);
            } else if(c == 'S') {
                channel_deskew_debug_ctrl_t deskew_ctrl;
                deskew_ctrl.ovr = 0;
                deskew_ctrl.offset_r = 0;
                deskew_ctrl.offset_g = 0;
                deskew_ctrl.offset_b = 0;
                dvi_set_channel_deskew_debug_ctrl(&deskew_ctrl);
            } else if(c == 'f') {
                framebuffers_control_t ctrl;
                dvi_get_framebuffers_control(&ctrl);
                ctrl.double_colordepth = !ctrl.double_colordepth;
                ctrl.high_res = 0;
                dvi_set_framebuffers_control(&ctrl);
                for (int i = 0; i < 100000; i++) { __asm__ __volatile__(""); }
                printf("%s double color depth.\n", ctrl.double_colordepth ? "Enabled" : "Disabled");
            } else if(c == 'h') {
                framebuffers_control_t ctrl;
                dvi_get_framebuffers_control(&ctrl);
                ctrl.double_colordepth = 0;
                ctrl.high_res = !ctrl.high_res;
                dvi_set_framebuffers_control(&ctrl);
                for (int i = 0; i < 100000; i++) { __asm__ __volatile__(""); }
                printf("%s high resolution.\n", ctrl.high_res ? "Enabled" : "Disabled");
            } else if(c == 'e') {
                configure_edid();
            } else if(c == 'r') {
                printf("Enter scaling factor: (current: %d)\n", step_factor);
                char c = fgetc(stdin);
                if(c > '0' && c <= '9')
                    step_factor = c - '0';
                else if(c >= 'a' && c <= 'z')
                    step_factor = c - 'a' + 10;
                else if(c >= 'A' && c <= 'Z')
                    step_factor = c - 'A' + 10;
                else
                    step_factor = 5;
                printf("New factor is: %d\n", step_factor);
            } else if(c == 'x') {
                framebuffers_control_t ctrl;
                dvi_get_framebuffers_control(&ctrl);

                printf("Enter column skip: (current: %d)\n", ctrl.skip_column);
                char c = fgetc(stdin);
                if(c >= '0' && c <= '9')
                    ctrl.skip_column = c - '0';
                dvi_set_framebuffers_control(&ctrl);
                for (int i = 0; i < 100000; i++) { __asm__ __volatile__(""); }
                printf("New column skip is: %d\n", ctrl.skip_column);
            } else if(c == 'y') {
                framebuffers_control_t ctrl;
                dvi_get_framebuffers_control(&ctrl);

                printf("Enter row skip: (current: %d)\n", ctrl.skip_row);
                char c = fgetc(stdin);
                if(c >= '0' && c <= '9')
                    ctrl.skip_row = c - '0';
                dvi_set_framebuffers_control(&ctrl);
                for (int i = 0; i < 100000; i++) { __asm__ __volatile__(""); }
                printf("New row skip is: %d\n", ctrl.skip_row);
            } else if(c == 'i') {
                print_framebuffer_interrupts = !print_framebuffer_interrupts;
                printf("%s interrupt printing.\n", print_framebuffer_interrupts ? "Enabled" : "Disabled");
            } else if (c == '?') {
                printf(
                    "\n"
                    "c or ENTER \t continue"
                    "d \t dump framebuffer\n"
                    "p \t print frame into terminal\n"
                    "P \t print frame into terminal (repeatedly)\n"
                    "s \t calibrate channel deskew in software\n"
                    "S \t set channel deskew values to 000\n"
                    "f \t toggle double colordepth mode\n"
                    "h \t toggle high res mode\n"
                    "e \t configure edid\n"
                    "r \t change scaling factor\n"
                    "x \t set skip column for framebuffer\n"
                    "y \t set skip row for framebuffer\n"
                    "i \t toggle framebuffer interrupts\n"
                    "? \t help\n"
                    );
            }
            printf("\n");
        }
    }

    return 0;
}
