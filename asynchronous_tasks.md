# Asynchronous Tasks in Fortran

## Introduction

The principle of asynchrony is fundamental to many aspects of computing,
and appears in many forms, many of which already overlap with the use of
Fortran.  Fortran supports asynchronous execution already via coarrays,
since two coarrays execute independent of one another unless explicitly
synchronized.  However, some use cases for asynchrony are a poor fit for
coarrays, either due to the need for data to be distributed across images
and explicitly communicated between them, or because the number of images
is fixed and - except for termination - does not change throughout the
execution of a program.

It is also possible to achieve asynchrony using DO CONCURRENT, but this
assumes that an implementation generates the appropriate type of paralleism
required for asynchronous execution.  In any case, DO CONCURRENT imposes
a number of restrictions on the code that can be executed within that scope,
particularly that impure procedures are not permitted.  This excludes the
possibility of long-running and/or complex tasks that cannot be contorted
to fit within the scope of a single DO CONCURRENT region.

## Related Efforts

Ada, C and C++ are ISO languages with support for asynchronous
execution in one form another, with features introduced in
1995, 2011 and 2011, respectively.  We will briefly highlight the
asynchronous parts of these languages below.

Within the domain of high-performance computing (HPC), the standardized
directives known as OpenMP and OpenACC support asynchronous execution,
which is used in Fortran applications today.  The use cases for
directive-based asynchronous execution in Fortran applications provide
use cases for the features we are proposing.

### Ada Tasks

Ada has tasks a first-class feature in the language.  Ada tasks are
similar to OS threads, in that they can act asynchronously relative
to their parent, and can act on data from the parent scope, for
example with a discriminate (argument) that is a pointer to data
allocated and initialized elsewhere.
In contrast to coarrays, Ada tasks can be created and destroyed
within a program, tasks can create and wait on additional tasks,
and tasks can access global variables.

https://dwheeler.com/lovelace/s13s1.htm

### C Threads

The ISO C11 language introduced both threads and atomic operations,
which are primitives that allow the implementation of asynchronous
execution similar to Ada tasks.  For example, the user can spawn
a thread, provide it with pointers to data that it can manipulate.
Because C provides nothing like Ada's protected objects, users
must take care and use atomic operations when multiple threads
access data concurrently.  Users can also built their own protected
accesses using mutexes.

### C++ Threads

C++11 added equivalent features to C11 - threads, atomics, mutexes -
as well as related features like async, promise and future.
In later versions of the standard, C++ has introduced parallel
algorithms (e.g. std::for_each, which has the ability to behave
like Fortran 2008 DO CONCURRENT).

### OpenMP Tasks

OpenMP 






