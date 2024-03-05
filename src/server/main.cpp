#include "mongoose.h"
#include "sqlite3.h"
#include "sqlite3ext.h"

#include <pthread.h>
#include <stdio.h>

// Mongoose event handler function
static void fn(struct mg_connection *c, int ev, void *ev_data, void *fn_data)
{
    if (ev == MG_EV_HTTP_MSG)
    {
        struct mg_http_message *hm = (struct mg_http_message *)ev_data;

        // Serve static content from the 'static' directory
        struct mg_http_serve_opts opts = {.root_dir = "static"};

        // Serve files directly without specific URI matching
        mg_http_serve_dir(c, hm, &opts);
    }
}

int main(void)
{
    struct mg_mgr mgr;
    mg_mgr_init(&mgr);                                       // Init manager
    mg_http_listen(&mgr, "http://127.0.0.1:8080", fn, NULL); // Setup listener

    for (;;)
    {
        mg_mgr_poll(&mgr, 1000); // Infinite event loop
    }

    mg_mgr_free(&mgr);
    return 0;
}
