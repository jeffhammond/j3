module m
    interface
        subroutine f(i,x)
            implicit none
            integer, intent(in) :: i
            double precision, intent(out) :: x
        end subroutine f
    end interface
    contains 
        subroutine fake(i,x)
            implicit none
            integer, intent(in) :: i
            double precision, intent(out) :: x
            stop
        end subroutine fake
end module m
