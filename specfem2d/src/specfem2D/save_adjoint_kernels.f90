
!========================================================================
!
!                   S P E C F E M 2 D  Version 7 . 0
!                   --------------------------------
!
!     Main historical authors: Dimitri Komatitsch and Jeroen Tromp
!                        Princeton University, USA
!                and CNRS / University of Marseille, France
!                 (there are currently many more authors!)
! (c) Princeton University and CNRS / University of Marseille, April 2014
!
! This software is a computer program whose purpose is to solve
! the two-dimensional viscoelastic anisotropic or poroelastic wave equation
! using a spectral-element method (SEM).
!
! This software is governed by the CeCILL license under French law and
! abiding by the rules of distribution of free software. You can use,
! modify and/or redistribute the software under the terms of the CeCILL
! license as circulated by CEA, CNRS and Inria at the following URL
! "http://www.cecill.info".
!
! As a counterpart to the access to the source code and rights to copy,
! modify and redistribute granted by the license, users are provided only
! with a limited warranty and the software's author, the holder of the
! economic rights, and the successive licensors have only limited
! liability.
!
! In this respect, the user's attention is drawn to the risks associated
! with loading, using, modifying and/or developing or reproducing the
! software by the user in light of its specific status of free software,
! that may mean that it is complicated to manipulate, and that also
! therefore means that it is reserved for developers and experienced
! professionals having in-depth computer knowledge. Users are therefore
! encouraged to load and test the software's suitability as regards their
! requirements in conditions enabling the security of their systems and/or
! data to be ensured and, more generally, to use and operate it in the
! same conditions as regards security.
!
! The full text of the license is available in file "LICENSE".
!
!========================================================================

subroutine save_adjoint_kernels()

  use specfem_par, only : myrank, nspec, ibool, coord, save_ASCII_kernels, &
                          any_acoustic, any_elastic, any_poroelastic, &
                          rho_ac_kl, kappa_ac_kl, alpha_ac_kl, rhop_ac_kl, &
                          rho_kl, kappa_kl, mu_kl, rhop_kl, alpha_kl, beta_kl, &
                          bulk_c_kl, bulk_beta_kl, &
                          rhorho_ac_hessian_final1, rhorho_ac_hessian_final2, &
                          rhorho_el_hessian_final1, rhorho_el_hessian_final2, &
                          rhot_kl, rhof_kl, sm_kl, eta_kl, mufr_kl, B_kl, &
                          C_kl, M_kl, rhob_kl, rhofb_kl, phi_kl, Bb_kl, Cb_kl, Mb_kl, mufrb_kl, &
                          rhobb_kl, rhofbb_kl, phib_kl, cpI_kl, cpII_kl, cs_kl, ratio_kl, GPU_MODE, &
                          hti_ec_rho_kl,hti_ec_c11_kl,hti_ec_c13_kl,hti_ec_c33_kl,hti_ec_c55_kl, &
                          hti_thom_rhop_kl,hti_thom_alpha_kl,hti_thom_beta_kl,&
                          hti_thom_epsilon_kl,hti_thom_delta_kl,ANISO, M_PAR, &
                          pdh_hti_ec_c11, pdh_hti_ec_c13, pdh_hti_ec_c33, pdh_hti_ec_c55, pdh_hti_ec_rho, &
                          pdh_hti_thom_alpha, pdh_hti_thom_beta, pdh_hti_thom_epsilon, pdh_hti_thom_delta, &
                          pdh_hti_thom_rhop,&
                          Qalpha_kl,Qbeta_kl,Qkappa_kl,Qmu_kl

  include "constants.h"

  integer :: i, j, ispec, iglob
  double precision :: xx, zz

  if ( myrank == 0 ) then
    write(IOUT,*) 'Writing Kernels file'
  endif

  if(any_acoustic) then
    if(save_ASCII_kernels) then ! ascii format
      do ispec = 1, nspec
        do j = 1, NGLLZ
          do i = 1, NGLLX
            iglob = ibool(i,j,ispec)
            xx = coord(1,iglob)
            zz = coord(2,iglob)
            write(95,'(4e15.5e4)')xx,zz,rho_ac_kl(i,j,ispec),kappa_ac_kl(i,j,ispec)
            write(96,'(4e15.5e4)')xx,zz,rhop_ac_kl(i,j,ispec),alpha_ac_kl(i,j,ispec)
            !write(96,'(4e15.5e4)')rhorho_ac_hessian_final1(i,j,ispec),
            !rhorho_ac_hessian_final2(i,j,ispec),&
            !                rhop_ac_kl(i,j,ispec),alpha_ac_kl(i,j,ispec)
          enddo
        enddo
      enddo
      close(95)
      close(96)

    else ! binary format
       write(200)rho_ac_kl
       write(201)kappa_ac_kl
       write(202)rhop_ac_kl
       write(203)alpha_ac_kl
       close(200)
       close(201)
       close(202)
       close(203)

      if (SAVE_DIAGONAL_HESSIAN) then
        write(212)rhorho_ac_hessian_final1
        write(213)rhorho_ac_hessian_final2
        close(212)
        close(213)
      endif

    endif
  endif

  if(any_elastic) then
    if(save_ASCII_kernels)then ! ascii format
    do ispec = 1, nspec
        do j = 1, NGLLZ
          do i = 1, NGLLX
            iglob = ibool(i,j,ispec)
            xx = coord(1,iglob)
            zz = coord(2,iglob)
            write(97,'(5e15.5e4)')xx,zz,rho_kl(i,j,ispec),kappa_kl(i,j,ispec),mu_kl(i,j,ispec)
            write(98,'(5e15.5e4)')xx,zz,rhop_kl(i,j,ispec),alpha_kl(i,j,ispec),beta_kl(i,j,ispec)
            !write(98,'(5e15.5e4)')rhorho_el_hessian_final1(i,j,ispec),
            !rhorho_el_hessian_final2(i,j,ispec),&
            !rhop_kl(i,j,ispec),alpha_kl(i,j,ispec),beta_kl(i,j,ispec)
          enddo
        enddo
      enddo
      close(97)
      close(98)
    else if (ANISO) then
     if ((trim(M_PAR) == 'htiec')) then
      write(216)hti_ec_rho_kl
      write(217)hti_ec_c11_kl
      write(218)hti_ec_c13_kl
      write(219)hti_ec_c33_kl
      write(220)hti_ec_c55_kl
      close(216)
      close(217)
      close(218)
      close(219)
      close(220)
      write(226)pdh_hti_ec_c11
      write(227)pdh_hti_ec_c13
      write(228)pdh_hti_ec_c33
      write(229)pdh_hti_ec_c55
      write(230)pdh_hti_ec_rho
      close(226)
      close(227)
      close(228)
      close(229)
      close(230)
     endif
     if ((trim(M_PAR) == 'htithom')) then
      write(221)hti_thom_rhop_kl
      write(222)hti_thom_alpha_kl
      write(223)hti_thom_beta_kl
      write(224)hti_thom_epsilon_kl
      write(225)hti_thom_delta_kl
      close(221)
      close(222)
      close(223)
      close(224)
      close(225)
      write(231)pdh_hti_thom_alpha
      write(232)pdh_hti_thom_beta
      write(233)pdh_hti_thom_epsilon
      write(234)pdh_hti_thom_delta
      write(235)pdh_hti_thom_rhop
      close(231)
      close(232)
      close(233)
      close(234)
      close(235)
     endif
    else if (.not. ANISO) then! binary format
      write(207)rhop_kl
      write(208)alpha_kl
      write(209)beta_kl
      close(207)
      close(208)
      close(209)
      write(204)rho_kl
      write(205)kappa_kl
      write(206)mu_kl
      close(204)
      close(205)
      close(206)
      write(210)Qkappa_kl
      write(211)Qmu_kl
      close(210)
      close(211)

      if (SAVE_DIAGONAL_HESSIAN) then
        write(214)rhorho_el_hessian_final1
        write(215)rhorho_el_hessian_final2
        close(214)
        close(215)
      endif

    endif
  endif

if (.not. GPU_MODE )  then

  if(any_poroelastic) then

      if (.not. SAVE_ASCII_KERNELS) stop 'poroelastic simulations must use SAVE_ASCII_KERNELS'

    do ispec = 1, nspec
      do j = 1, NGLLZ
        do i = 1, NGLLX
          iglob = ibool(i,j,ispec)
          xx = coord(1,iglob)
          zz = coord(2,iglob)
          write(144,'(5e11.3)')xx,zz,mufr_kl(i,j,ispec),B_kl(i,j,ispec),C_kl(i,j,ispec)
          write(155,'(5e11.3)')xx,zz,M_kl(i,j,ispec),rhot_kl(i,j,ispec),rhof_kl(i,j,ispec)
          write(16,'(5e11.3)')xx,zz,sm_kl(i,j,ispec),eta_kl(i,j,ispec)
          write(17,'(5e11.3)')xx,zz,mufrb_kl(i,j,ispec),Bb_kl(i,j,ispec),Cb_kl(i,j,ispec)
          write(18,'(5e11.3)')xx,zz,Mb_kl(i,j,ispec),rhob_kl(i,j,ispec),rhofb_kl(i,j,ispec)
          write(19,'(5e11.3)')xx,zz,phi_kl(i,j,ispec),eta_kl(i,j,ispec)
          write(20,'(5e11.3)')xx,zz,cpI_kl(i,j,ispec),cpII_kl(i,j,ispec),cs_kl(i,j,ispec)
          write(21,'(5e11.3)')xx,zz,rhobb_kl(i,j,ispec),rhofbb_kl(i,j,ispec),ratio_kl(i,j,ispec)
          write(22,'(5e11.3)')xx,zz,phib_kl(i,j,ispec),eta_kl(i,j,ispec)
        enddo
      enddo
    enddo
    close(144)
    close(155)
    close(16)
    close(17)
    close(18)
    close(19)
    close(20)
    close(21)
    close(22)
  endif

endif

end subroutine save_adjoint_kernels

