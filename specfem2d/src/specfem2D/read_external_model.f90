
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
!               Pieyre Le Loher, pieyre DOT le-loher aT inria.fr
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

  subroutine read_external_model()
  ! PWY added new parameter ANISO
  use specfem_par, only: any_acoustic,any_gravitoacoustic,any_elastic,any_poroelastic, &
                         acoustic,gravitoacoustic,elastic,poroelastic,anisotropic,nspec,nglob,ibool, &
                         READ_VELOCITIES_AT_f0,inv_tau_sigma_nu1_sent,&
                         phi_nu1_sent,inv_tau_sigma_nu2_sent,phi_nu2_sent,Mu_nu1_sent,Mu_nu2_sent, &
                         inv_tau_sigma_nu1,inv_tau_sigma_nu2,phi_nu1,phi_nu2,Mu_nu1,Mu_nu2,&
                         coord,kmato,rhoext,vpext,vsext,gravityext,Nsqext, &
                         QKappa_attenuationext,Qmu_attenuationext, &
                         c11ext,c13ext,c15ext,c33ext,c35ext,c55ext,c12ext,c23ext,c25ext, &
                         MODEL,ANISO,ATTENUATION_VISCOELASTIC_SOLID,p_sv,&
                         inputname,ios,tomo_material, myrank, ANISO, M_PAR

  implicit none
  include "constants.h"


  ! Local variables
  integer :: i,j,ispec,iglob
  real(kind=CUSTOM_REAL) :: previous_vsext
  real(kind=CUSTOM_REAL) :: tmp1, tmp2,tmp3
  double precision :: rho_dummy,vp_dummy,vs_dummy,mu_dummy,lambda_dummy
  !! read anisotropic parameters with thomsen parameterization
  real(kind=4),dimension(:,:,:),allocatable :: hti_thom_vpext, hti_thom_vsext, hti_thom_epsilonext
  real(kind=4),dimension(:,:,:),allocatable :: hti_thom_deltaext, hti_thom_rhopext

  if (ANISO .and. (trim(M_PAR)=='htithom')) then
   allocate(hti_thom_rhopext(NGLLX,NGLLZ,nspec))
   allocate(hti_thom_vpext(NGLLX,NGLLZ,nspec))
   allocate(hti_thom_vsext(NGLLX,NGLLZ,nspec))
   allocate(hti_thom_epsilonext(NGLLX,NGLLZ,nspec))
   allocate(hti_thom_deltaext(NGLLX,NGLLZ,nspec)) 
  endif

   if (tomo_material > 0)  MODEL = 'tomo'

  if(trim(MODEL) == 'legacy') then

    write(inputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_model_velocity.dat_input'
    open(unit=1001,file=inputname,status='unknown')
    do ispec = 1,nspec
      do j = 1,NGLLZ
        do i = 1,NGLLX
          iglob = ibool(i,j,ispec)
          read(1001,*) tmp1,tmp2,tmp3,rhoext(i,j,ispec),vpext(i,j,ispec),vsext(i,j,ispec)
          QKappa_attenuationext(i,j,ispec) = 9999.d0
          Qmu_attenuationext(i,j,ispec) = 9999.d0
        enddo
      enddo
    enddo
    close(1001)


  else if(trim(MODEL)=='ascii') then
    write(inputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_rho_vp_vs.dat'
    open(unit=1001,file= inputname,status='unknown')
    do ispec = 1,nspec
      do j = 1,NGLLZ
        do i = 1,NGLLX
          iglob = ibool(i,j,ispec)
          read(1001,*) tmp1,tmp2,rhoext(i,j,ispec),vpext(i,j,ispec),vsext(i,j,ispec)
          QKappa_attenuationext(i,j,ispec) = 9999.d0
          Qmu_attenuationext(i,j,ispec) = 9999.d0
        enddo
      enddo
    enddo
    close(1001)

  else if((trim(MODEL) == 'binary') .or. (trim(MODEL) == 'gll')) then
      write(inputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_rho.bin'
      open(unit = 1001, file = inputname, status='old',action='read',form='unformatted', iostat=ios)
      if (ios /= 0) stop 'Error opening rho.bin file.'

      read(1001) rhoext
      close(1001)
   !   print *, 'rho', minval(rhoext), maxval(rhoext)
    if (.not. ANISO) then
      write(inputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_vp.bin'
      open(unit = 1001, file = inputname, status='old',action='read',form='unformatted', iostat=ios)
      if (ios /= 0) stop 'Error opening vp.bin file.'

      read(1001) vpext
      close(1001)

      write(inputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_vs.bin'
      open(unit = 1001, file = inputname, status='old',action='read',form='unformatted', iostat=ios)
      if (ios /= 0) stop 'Error opening vs.bin file.'

      read(1001) vsext
      close(1001)
    endif
    if (ANISO .and. (trim(M_PAR)=='htiec')) then
      write(inputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_c11.bin'
      open(unit = 1001, file = inputname, status='old',action='read',form='unformatted', iostat=ios)
      if (ios /= 0) stop 'Error opening rho.bin file.'

      read(1001) c11ext
      close(1001)

      write(inputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_c13.bin'
      open(unit = 1001, file = inputname,status='old',action='read',form='unformatted', iostat=ios)
      if (ios /= 0) stop 'Error opening rho.bin file.'

      read(1001) c13ext
      close(1001)

      write(inputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_c15.bin'
      open(unit = 1001, file = inputname, status='old',action='read',form='unformatted', iostat=ios)
      if (ios /= 0) stop 'Error opening rho.bin file.'

      read(1001) c15ext
      close(1001)

      write(inputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_c33.bin'
      open(unit = 1001, file = inputname, status='old',action='read',form='unformatted', iostat=ios)
      if (ios /= 0) stop 'Error opening rho.bin file.'

      read(1001) c33ext
      close(1001)

      write(inputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_c35.bin'
      open(unit = 1001, file = inputname, status='old',action='read',form='unformatted', iostat=ios)
      if (ios /= 0) stop 'Error opening rho.bin file.'

      read(1001) c35ext
      close(1001)

      write(inputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_c55.bin'
      open(unit = 1001, file = inputname,status='old',action='read',form='unformatted', iostat=ios)
      if (ios /= 0) stop 'Error opening rho.bin file.'

      read(1001) c55ext
      close(1001)

      write(inputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_c12.bin'
      open(unit = 1001, file = inputname,status='old',action='read',form='unformatted', iostat=ios)
      if (ios /= 0) stop 'Error opening rho.bin file.'

      read(1001) c12ext
      close(1001)

      write(inputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_c23.bin'
      open(unit = 1001, file = inputname, status='old',action='read',form='unformatted', iostat=ios)
      if (ios /= 0) stop 'Error opening rho.bin file.'

      read(1001) c23ext
      close(1001)

      write(inputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_c25.bin'
      open(unit = 1001, file = inputname, status='old',action='read',form='unformatted', iostat=ios)
      if (ios /= 0) stop 'Error opening rho.bin file.'

      read(1001) c25ext
      close(1001)

      do ispec = 1,nspec
        do j = 1,NGLLZ
          do i = 1,NGLLX
            iglob = ibool(i,j,ispec)
            vpext(i,j,ispec) = SQRT(c33ext(i,j,ispec)/rhoext(i,j,ispec))
            vsext(i,j,ispec) = SQRT(c55ext(i,j,ispec)/rhoext(i,j,ispec))
          enddo
        enddo
      enddo
    endif
    if (ANISO .and. (trim(M_PAR)=='htithom')) then
      write(inputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_hti_thom_vp.bin'
      open(unit = 1001, file = inputname, status='old',action='read',form='unformatted', iostat=ios)
      if (ios /= 0) stop 'Error opening hti_thom_vp.bin file.'

      read(1001) hti_thom_vpext
      close(1001)

      write(inputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_hti_thom_vs.bin'
      open(unit = 1001, file = inputname, status='old',action='read',form='unformatted', iostat=ios)
      if (ios /= 0) stop 'Error opening hti_thom_vs.bin file.'

      read(1001) hti_thom_vsext
      close(1001)

      write(inputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_hti_thom_rhop.bin'
      open(unit = 1001, file = inputname, status='old',action='read',form='unformatted', iostat=ios)
      if (ios /= 0) stop 'Error opening hti_thom_rhop.bin file.'

      read(1001) hti_thom_rhopext
      close(1001)

      write(inputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_hti_thom_epsilon.bin'
      open(unit = 1001, file = inputname, status='old',action='read',form='unformatted', iostat=ios)
      if (ios /= 0) stop 'Error opening hti_thom_epsilon.bin file.'

      read(1001) hti_thom_epsilonext
      close(1001)

      write(inputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_hti_thom_delta.bin'
      open(unit = 1001, file = inputname, status='old',action='read',form='unformatted', iostat=ios)
      if (ios /= 0) stop 'Error opening hti_thom_delta.bin file.'

      read(1001) hti_thom_deltaext
      close(1001)

      do ispec = 1,nspec
        do j = 1,NGLLZ
          do i = 1,NGLLX
            iglob = ibool(i,j,ispec)
            c11ext(i,j,ispec) = hti_thom_rhopext(i,j,ispec)*hti_thom_vpext(i,j,ispec)**2*&
              (2._CUSTOM_REAL*hti_thom_epsilonext(i,j,ispec)+1._CUSTOM_REAL)

            c13ext(i,j,ispec) = SQRT(2._CUSTOM_REAL*hti_thom_rhopext(i,j,ispec)*&
            hti_thom_deltaext(i,j,ispec)*hti_thom_vpext(i,j,ispec)**2*(hti_thom_rhopext(i,j,ispec)*&
            hti_thom_vpext(i,j,ispec)**2-hti_thom_rhopext(i,j,ispec)*hti_thom_vsext(i,j,ispec)**2)+&
            (hti_thom_rhopext(i,j,ispec)*hti_thom_vpext(i,j,ispec)**2-&
            hti_thom_rhopext(i,j,ispec)*hti_thom_vsext(i,j,ispec)**2)**2)-&
            hti_thom_rhopext(i,j,ispec)*hti_thom_vsext(i,j,ispec)**2

            c33ext(i,j,ispec) = hti_thom_rhopext(i,j,ispec)*hti_thom_vpext(i,j,ispec)**2

            c55ext(i,j,ispec) = hti_thom_rhopext(i,j,ispec)*hti_thom_vsext(i,j,ispec)**2
            c12ext(i,j,ispec) = 0.0d0
            c15ext(i,j,ispec) = 0.0d0
            c23ext(i,j,ispec) = 0.0d0
            c25ext(i,j,ispec) = 0.0d0
            c35ext(i,j,ispec) = 0.0d0
            vsext(i,j,ispec) = hti_thom_vsext(i,j,ispec)
            vpext(i,j,ispec) = hti_thom_vpext(i,j,ispec)
            rhoext(i,j,ispec) = hti_thom_rhopext(i,j,ispec)
          enddo
        enddo
      enddo
    endif
    if (ATTENUATION_VISCOELASTIC_SOLID ) then !YY
      !! input QKappa -- !YY
          write(inputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_QKappa.bin'   
          open(unit = 1001, file = inputname,status='old',action='read',form='unformatted',iostat=ios)  
          if (ios /= 0) stop 'Error opening Qmu.bin file.'
          read(1001) QKappa_attenuationext
          close(1001)

      !! input Qmu -- !YY
          write(inputname,'(a,i6.6,a)') 'DATA/proc',myrank,'_Qmu.bin'
          open(unit = 1001, file = inputname,status='old',action='read',form='unformatted', iostat=ios)
          if (ios /= 0) stop 'Error opening Qmu.bin file.'
          read(1001) Qmu_attenuationext
          close(1001)
      else
          QKappa_attenuationext(:,:,:) = 9999.d0
          Qmu_attenuationext(:,:,:) = 9999.d0
      endif

  else if(trim(MODEL)=='external') then
    call define_external_model(coord,kmato,ibool,rhoext,vpext,vsext,QKappa_attenuationext,Qmu_attenuationext,gravityext,Nsqext, &
                               c11ext,c13ext,c15ext,c33ext,c35ext,c55ext,c12ext,c23ext,c25ext,nspec,nglob)
  else if(trim(MODEL)=='tomo') then
    call define_external_model_from_tomo_file_aniso()
  endif

      if(.not. ATTENUATION_VISCOELASTIC_SOLID) then
          QKappa_attenuationext(:,:,:) = 9999.d0
          Qmu_attenuationext(:,:,:) = 9999.d0
      endif


  if(myrank==0) then
      print*, 'input model type -- ',trim(MODEL) !YY
      print*, 'YY, min/max of rhoext --',&
          minval(rhoext(:,:,:)),maxval(rhoext(:,:,:))
      print*, 'YY, min/max of vpext --',&
          minval(vpext(:,:,:)),maxval(vpext(:,:,:))
      print*, 'YY, min/max of vsext --',&
          minval(vsext(:,:,:)),maxval(vsext(:,:,:))
      print*, 'YY, min/max of QKappa_ext --',&
          minval(QKappa_attenuationext(:,:,:)),maxval(QKappa_attenuationext(:,:,:))
      print*, 'YY, min/max of Qmu_ext --',&
          minval(Qmu_attenuationext(:,:,:)),maxval(Qmu_attenuationext(:,:,:))
  endif

!  if(trim(MODEL)=='external' .or. trim(MODEL)=='tomo') then !YY -- not check for tomo model
  if(trim(MODEL)=='external') then 
    ! check that the external model that has just been defined makes sense
    do ispec = 1,nspec
      do j = 1,NGLLZ
        do i = 1,NGLLX

          if(c11ext(i,j,ispec) > TINYVAL .or. c13ext(i,j,ispec) > TINYVAL .or. c15ext(i,j,ispec) > TINYVAL .or. &
             c33ext(i,j,ispec) > TINYVAL .or. c35ext(i,j,ispec) > TINYVAL .or. c55ext(i,j,ispec) > TINYVAL) then
            ! vp, vs : assign dummy values, trick to avoid floating point errors in the case of an anisotropic medium
            vpext(i,j,ispec) = 20.d0
            vsext(i,j,ispec) = 10.d0
          endif

          ! check that the element type is not redefined compared to what is defined initially in DATA/Par_file
          if((c11ext(i,j,ispec) > TINYVAL .or. c13ext(i,j,ispec) > TINYVAL .or. c15ext(i,j,ispec) > TINYVAL .or. &
              c33ext(i,j,ispec) > TINYVAL .or. c35ext(i,j,ispec) > TINYVAL .or. c55ext(i,j,ispec) > TINYVAL) &
              .and. .not. anisotropic(ispec)) &
      stop 'error: non anisotropic material in DATA/Par_file or external mesh redefined as anisotropic in define_external_model()'

          if(vsext(i,j,ispec) < TINYVAL .and. (elastic(ispec) .or. anisotropic(ispec))) &
            stop 'error: non acoustic material in DATA/Par_file or external mesh redefined as acoustic in define_external_model()'

          if(vsext(i,j,ispec) > TINYVAL .and. .not. elastic(ispec)) &
            stop 'error: acoustic material in DATA/Par_file or external mesh redefined as non acoustic in define_external_model()'

        enddo
      enddo
    enddo

  endif

  ! initializes
  any_acoustic = .false.
  any_gravitoacoustic = .false.
  any_elastic = .false.
  any_poroelastic = .false.

  acoustic(:) = .false.
  gravitoacoustic(:) = .false.
  anisotropic(:) = .false.
  elastic(:) = .false.
  poroelastic(:) = .false.

! initialize to dummy values
! convention to indicate that Q = 9999 in that element i.e. that there is no viscoelasticity in that element
  inv_tau_sigma_nu1(:,:,:,:) = -1._CUSTOM_REAL
  phi_nu1(:,:,:,:) = -1._CUSTOM_REAL
  inv_tau_sigma_nu2(:,:,:,:) = -1._CUSTOM_REAL
  phi_nu2(:,:,:,:) = -1._CUSTOM_REAL
  Mu_nu1(:,:,:) = -1._CUSTOM_REAL
  Mu_nu2(:,:,:) = -1._CUSTOM_REAL

  do ispec = 1,nspec

    previous_vsext = vsext(1,1,ispec)

    do j = 1,NGLLZ
      do i = 1,NGLLX
        iglob = ibool(i,j,ispec)


        if(p_sv .and. (.not. (i == 1 .and. j == 1)) .and. &
          ((vsext(i,j,ispec) >= TINYVAL .and. previous_vsext < TINYVAL) .or. &
           (vsext(i,j,ispec) < TINYVAL  .and. previous_vsext >= TINYVAL)))  &
          call exit_MPI('external velocity model cannot be both fluid and solid inside the same spectral element')

        if(c11ext(i,j,ispec) > TINYVAL .or. c13ext(i,j,ispec) > TINYVAL .or. c15ext(i,j,ispec) > TINYVAL .or. &
           c33ext(i,j,ispec) > TINYVAL .or. c35ext(i,j,ispec) > TINYVAL .or. c55ext(i,j,ispec) > TINYVAL) then
          if (ANISO) then
            anisotropic(ispec) = .true.
          endif
          poroelastic(ispec) = .false.
          elastic(ispec) = .true.
          any_elastic = .true.
!          QKappa_attenuationext(i,j,ispec) = 9999.d0 !! PWY
!          Qmu_attenuationext(i,j,ispec) = 9999.d0 !! PWY
        else if((vsext(i,j,ispec) < TINYVAL) .and. (gravityext(i,j,ispec) < TINYVAL)) then
          elastic(ispec) = .false.
          poroelastic(ispec) = .false.
          gravitoacoustic(ispec)=.false.
          acoustic(ispec)=.true.
          any_acoustic = .true.
        else if((vsext(i,j,ispec) < TINYVAL) .and. (gravityext(i,j,ispec) >= TINYVAL)) then
          elastic(ispec) = .false.
          poroelastic(ispec) = .false.
          acoustic(ispec)=.false.
          gravitoacoustic(ispec)=.true.
          any_gravitoacoustic = .true.
        else
          poroelastic(ispec) = .false.
          elastic(ispec) = .true.
          any_elastic = .true.
        endif

!       attenuation is not implemented in acoustic (i.e. fluid) media for now, only in viscoelastic (i.e. solid) media
        if(acoustic(ispec)) cycle

!       check that attenuation values entered by the user make sense
        if((QKappa_attenuationext(i,j,ispec) <= 9998.999d0 .and. Qmu_attenuationext(i,j,ispec) >  9998.999d0) .or. &
           (QKappa_attenuationext(i,j,ispec) >  9998.999d0 .and. Qmu_attenuationext(i,j,ispec) <= 9998.999d0)) stop &
     'need to have Qkappa and Qmu both above or both below 9999 for a given material; trick: use 9998 if you want to turn off one'

!       if no attenuation in that elastic element
        if(QKappa_attenuationext(i,j,ispec) > 9998.999d0) cycle

        call attenuation_model(dble(QKappa_attenuationext(i,j,ispec)),dble(Qmu_attenuationext(i,j,ispec)))

        inv_tau_sigma_nu1(i,j,ispec,:) = inv_tau_sigma_nu1_sent(:)
        phi_nu1(i,j,ispec,:) = phi_nu1_sent(:)
        inv_tau_sigma_nu2(i,j,ispec,:) = inv_tau_sigma_nu2_sent(:)
        phi_nu2(i,j,ispec,:) = phi_nu2_sent(:)
        Mu_nu1(i,j,ispec) = Mu_nu1_sent
        Mu_nu2(i,j,ispec) = Mu_nu2_sent

        if(ATTENUATION_VISCOELASTIC_SOLID .and. READ_VELOCITIES_AT_f0) then
          if(anisotropic(ispec) .or. poroelastic(ispec) .or. gravitoacoustic(ispec)) stop &
             'READ_VELOCITIES_AT_f0 only implemented for non anisotropic, non poroelastic, non gravitoacoustic materials for now'

          vp_dummy = dble(vpext(i,j,ispec))
          vs_dummy = dble(vpext(i,j,ispec))
          rho_dummy = dble(rhoext(i,j,ispec))

          call shift_velocities_from_f0(vp_dummy,vs_dummy,rho_dummy,mu_dummy,lambda_dummy)

        endif

        previous_vsext = vsext(i,j,ispec)

      enddo
    enddo
  enddo

  end subroutine read_external_model

