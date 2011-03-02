/*
 * Copyright (c) 2011 University of Utah
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the copyright holders nor the names of its
 *   contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 * WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * @author Thomas schmid
 */

#include "hardware.h"
#include "sam3snvichardware.h"
#include "sam3spmchardware.h"
#include "sam3ssupchardware.h"
#include "sam3rtthardware.h"
//#include "sam3stchardware.h"

module McuSleepC
{
  provides{
    interface McuSleep;
    interface McuPowerState;
    interface Sam3LowPower;
    interface FunctionWrapper as InterruptWrapper;
  }
  uses {
    interface HplSam3Clock;
  }
}
implementation{
  #define PMC_PIO_CLOCK_MASK 0x3FFFFFFC

  enum {
    S_AWAKE,
    S_SLEEP,
    S_WAIT,
    S_BACKUP,
  };
  norace uint32_t ps;

  norace struct {
  } wait_restore;
  
  // This C function is defined so that we can call it
  // from platform_bootstrap(), as defined in platform.h
  void sam3LowPowerConfigure() @C() @spontaneous() {

    call Sam3LowPower.configure();
  }

  async command void Sam3LowPower.configure() {
    // Customize pio settings as appropriate for the platform
    signal Sam3LowPower.customizePio();
  }

  uint32_t getPowerState() {
    //if (PMC->pcsr.flat & PMC_PIO_CLOCK_MASK)
    if ((PMC->pc.pcsr.flat > 0) || (PMC->pc1.pcsr.flat > 0))
      return S_SLEEP;
    else 
      return S_WAIT;
  }

  void commonSleep() {
    // Check if any alarms are set for the tc2 alarm hardware.  
    // If not, turn off its peripheral clock
    // This is necessary because the TMicro alarm is linked to tc2.
    // More logic will need to be added here later, as more alarms are set up
    // for use.
    //if(!(TC->ch2.imr.bits.cpcs & 0x01))
    //  PMC->pcdr.bits.tc2 = 1;
  }

  void commonResume() {
    // Turn the periperhal clock for tc2 back on so that its alarm can be
    // set and times can be read from it
    //PMC->pcer.bits.tc2 = 1;
  }

  void setupSleepMode() {
    // Nothing special to do here yet
  }
  void resumeFromSleepMode() {
    // Nothing special to do here yet
  }

  void setupWaitMode() {
    // Save the state of the cpu we are about to change
    /*
    wait_restore.mck = call HplSam3Clock.getMainClockSpeed();
    wait_restore.adc_emr = ADC12B->emr;
    wait_restore.pmc_pcsr = PMC->pcsr;
    wait_restore.pmc_uckr = PMC->uckr;
    wait_restore.supc_mr = SUPC->mr;
    wait_restore.pioa_psr = AT91C_BASE_PIOA->PIO_PSR;
    wait_restore.piob_psr = AT91C_BASE_PIOB->PIO_PSR;
    wait_restore.pioc_psr = AT91C_BASE_PIOC->PIO_PSR;
    wait_restore.pioa_osr = AT91C_BASE_PIOA->PIO_OSR;
    wait_restore.piob_osr = AT91C_BASE_PIOB->PIO_OSR;
    wait_restore.pioc_osr = AT91C_BASE_PIOC->PIO_OSR;
    wait_restore.pioa_pusr = AT91C_BASE_PIOA->PIO_PPUSR;
    wait_restore.piob_pusr = AT91C_BASE_PIOB->PIO_PPUSR;
    wait_restore.pioc_pusr = AT91C_BASE_PIOC->PIO_PPUSR;
    */
    // Turn off all clocks to peripheral IO and configure pins
    // appropriately, so that when we go to sleep we are
    // drawing the least amount of current possible 
    call Sam3LowPower.configure();
    // Force us into 4 MHz with the RC Oscillator
    /*
    call HplSam3Clock.mckInit4RC(); 
    // Setup for wait mode 
    PMC->fsmr.bits.lpm = 1;
    // Only resume from wait mode with an input from the RTT
    PMC->fsmr.bits.rttal = 1;
    // Make sure we DON'T go into deep sleep (i.e. backup mode)
    SCB->scr.bits.sleepdeep = 0;
    */
  }

  void resumeFromWaitMode() {
    // Restore the old clock settings
    /*
    uint32_t oldMck = wait_restore.mck;
    if(oldMck > 13000 && oldMck < 49000){
      call HplSam3Clock.mckInit48();
    }else if(oldMck > 49000 && oldMck < 90000){
      call HplSam3Clock.mckInit84();
    }else if(oldMck > 90000){
      call HplSam3Clock.mckInit96();
    }
    // Restore the ADC to its previous mode
    ADC12B->emr = wait_restore.adc_emr;
    // Reenable peripheral clocks, as appropriate
    PMC->pcer.flat = wait_restore.pmc_pcsr.flat;
    PMC->pcdr.flat = ~wait_restore.pmc_pcsr.flat;
    // Reenable the UTMI clock, as appropriate
    PMC->uckr = wait_restore.pmc_uckr;
    // Reenable brownout detector, as appropriate
    {
      supc_mr_t mr;
      mr = wait_restore.supc_mr;
      mr.bits.key  = 0xA5;
      SUPC->mr = mr;
    }
    */
    // Restore the PIO output/input pin and pullup resistor
    // settings to the values they had before entering wait mode
    /*
    AT91C_BASE_PIOA->PIO_PER = wait_restore.pioa_psr; 
    AT91C_BASE_PIOB->PIO_PER = wait_restore.piob_psr; 
    AT91C_BASE_PIOC->PIO_PER = wait_restore.pioc_psr; 
    AT91C_BASE_PIOA->PIO_PDR = ~wait_restore.pioa_psr; 
    AT91C_BASE_PIOB->PIO_PDR = ~wait_restore.piob_psr; 
    AT91C_BASE_PIOC->PIO_PDR = ~wait_restore.pioc_psr; 

    AT91C_BASE_PIOA->PIO_OER = wait_restore.pioa_osr; 
    AT91C_BASE_PIOB->PIO_OER = wait_restore.piob_osr; 
    AT91C_BASE_PIOC->PIO_OER = wait_restore.pioc_osr; 
    AT91C_BASE_PIOA->PIO_ODR = ~wait_restore.pioa_osr; 
    AT91C_BASE_PIOB->PIO_ODR = ~wait_restore.piob_osr; 
    AT91C_BASE_PIOC->PIO_ODR = ~wait_restore.pioc_osr; 

    // Notice the reverse logic below - its on purpose, check the data sheet
    // 0 means active, 1 means inactive
    AT91C_BASE_PIOA->PIO_PPUER = ~wait_restore.pioa_pusr;
    AT91C_BASE_PIOB->PIO_PPUER = ~wait_restore.piob_pusr;
    AT91C_BASE_PIOC->PIO_PPUER = ~wait_restore.pioc_pusr;
    AT91C_BASE_PIOA->PIO_PPUDR = wait_restore.pioa_pusr;
    AT91C_BASE_PIOB->PIO_PPUDR = wait_restore.piob_pusr;
    AT91C_BASE_PIOC->PIO_PPUDR = wait_restore.pioc_pusr;
    */
  }

  void setupBackupMode() {
    // Not yet supported....
    // Need to think more about how to do this since it is essentially a "hibernate"
    //  mode, meaning we will have to save all register and memory state into 
    //  non-volatile memory. Possibly more state will need to be saved as well.
  }
  void resumeFromBackupMode() {
    // Not yet supported....
    // Need to think more about how to do this since it is essentially a "hibernate"
    //  mode and resuming will be from a reboot, not a simple interrupt service routine
    // Consider changing vectors.c to call out to this after checking some state variable
    // stored in the internal EEFC.
  }

  async command void McuSleep.sleep()
  {
    commonSleep();
    switch(ps = getPowerState()) {
      case S_AWAKE:
        //Just stay awake...
        break; 
      case S_SLEEP:
        // Setup for sleep mode
        setupSleepMode();
        break;
      case S_WAIT:
        // Setup for wait mode
        setupWaitMode();
        break;
      case S_BACKUP:
        // Setup for backup mode
        setupBackupMode();
        break;
      default:
        // Default setup
        setupSleepMode();
    }

    __nesc_enable_interrupt();

    // Enter appropriate idle mode
    if(ps != S_AWAKE)
      __asm volatile ("wfe");

    // Normally, at this point we can only be woken up by an interrupt, so execution continues
    // in the body of the InterruptWrapper.preamble() command before returning to here
    // However, if we never actually went to sleep, we need to force this command to run.
    if(ps == S_AWAKE)
      call InterruptWrapper.preamble();
  
    // all of memory may change at this point, because an IRQ handler
    // may have posted a task!
    asm volatile("" : : : "memory");

    __nesc_disable_interrupt();
  }

  async command void InterruptWrapper.preamble() {
    atomic {
      switch(ps) {
        case S_AWAKE:
          // Stayed awake the whole time, so do nothing
          break; 
        case S_SLEEP:
          // Resume from sleep mode
          resumeFromSleepMode();
          break;
        case S_WAIT:
          // Resume from wait mode
          resumeFromWaitMode();
          break;
        case S_BACKUP:
          // Resume from backup mode
          resumeFromBackupMode();
          break;
        default:
          // Default resume
          resumeFromSleepMode();
      }
      if(ps != S_AWAKE)
        commonResume();
      ps = S_AWAKE;
    }
  }
  async command void InterruptWrapper.postamble() { /* Do nothing */ }
  async command void McuPowerState.update(){}
  async event void HplSam3Clock.mainClockChanged(){}

  default async event void Sam3LowPower.customizePio() {}
}

