#!/usr/bin/awk -f
BEGIN{
    error_count=0;
    error_msg=""
}
{
    if( $0 ~ "31mERROR" )
    {
        error_msg=error_msg"\n"$0;
        error_count++
    };
    print $0
}
END{
    if(error_count == 0)
    {
        print "INFO No errors found on initialization"
        exit 0
    }
    else
    {
        print "ERROR "error_count" errors found in initialization\n"error_msg
        exit 1
    };
}