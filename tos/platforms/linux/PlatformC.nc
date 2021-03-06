// $Id: PlatformC.nc,v 1.4 2006/12/12 18:23:44 vlahan Exp $
/*
 * Copyright (c) 2005-2006 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */
/**
 * Dummy implementation to support the null platform.
 */
#include <ip_malloc.h>

module PlatformC { 
  provides interface Init;
}
implementation {
  command error_t Init.init() {
    linux_dbg_init();
    ip_malloc_init();
    
    return SUCCESS;
  }
}
