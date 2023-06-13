module m
    contains
        subroutine fimpl(i,x) ! bind(Fortran,"f")
            implicit none
            integer, intent(in) :: i
            double precision, intent(out) :: x
            x = i * 3.7
        end subroutine fimpl
end module m

! if not bind(Fortran)
subroutine f(i,x)
    use mimpl, only : fimpl
    implicit none
    integer, intent(in) :: i
    double precision, intent(out) :: x
    call fimpl(i,x)
end subroutine f

