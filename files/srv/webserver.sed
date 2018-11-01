#!/bin/sed -nrf

:START
/\r?\n\r?$/bRESPONSE; N; bSTART;

:RESPONSE

/\nHost: oktopus\r?\n/{
s;^.*$;;;
iHTTP/1.1 200 OK\r\
Content-Type: text/html; encoding=utf-8\r\
Connection: close\r\
\r\
<HTML><HEAD><TITLE>Oktopus</TITLE></HEAD><BODY><H1>Oktopus</H1>Oktopus</BODY></HTML>
p
q
}

s;^.*$;;;
iHTTP/1.1 307 Temporary Redirect\r\
Location: http://oktopus\r\
Connection: close\r\
\r\
p
q
