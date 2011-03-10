#include "RFA1IeeeEui64.h"

module RFA1IeeeEui64C {
  provides {
    interface LocalIeeeEui64;
  }
} implementation {

  /** Read from dedicated AVR registers */
  command ieee_eui64_t LocalIeeeEui64.getId() {

  ieee_eui64_t m_eui;

    atomic { 
      m_eui.data[0] = IEEE_ADDR_0;
      m_eui.data[1] = IEEE_ADDR_1;
      m_eui.data[2] = IEEE_ADDR_2;
      m_eui.data[3] = IEEE_ADDR_3;
      m_eui.data[4] = IEEE_ADDR_4;
      m_eui.data[5] = IEEE_ADDR_5;
      m_eui.data[6] = IEEE_ADDR_6;
      m_eui.data[7] = IEEE_ADDR_7;
    }
  return m_eui;
  }

  /** Write to dedicated AVR registers */
  /*
  command void LocalIeeeEui64.setId(ieee_eui64_t m_eui) {

    atomic { 
      IEEE_ADDR_0 = m_eui.data[0];
      IEEE_ADDR_1 = m_eui.data[1];
      IEEE_ADDR_2 = m_eui.data[2];
      IEEE_ADDR_3 = m_eui.data[3];
      IEEE_ADDR_4 = m_eui.data[4];
      IEEE_ADDR_5 = m_eui.data[5];
      IEEE_ADDR_6 = m_eui.data[6];
      IEEE_ADDR_7 = m_eui.data[7];
    }
  } */
}
