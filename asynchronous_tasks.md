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

OpenMP 3.1 introduced tasks on top of the existing threading model.
The 3.1 version of tasks did not support dependencies, other than
parent tasks waiting on child tasks.  In OpenMP 4.0, task
dependencies were introduced, which permitted the synchronization
of tasks using memory locations as identifiers.  The implementation
of task dependencies is considerably more complicated, and is
a cautionary tale for Fortran.

### OpenACC Async

OpenACC has `async`, which provides a queue-like mechanism for
allowing asynchronous execution of certain features.  This is
a natural match when OpenACC targets another device, such as a
GPU, which natural executives asynchronously relative to the
host controlling it.

OpenACC `async` does not allow interactions between different
asynchonrous regions, and furthermore offers multiple streams
of asynchrony, enumerated as integers.  Because asynchronous
regions cannot interact, it is legal for an implementation to
ignore asynchrony and wait for completion of such regions
before proceeding.  This allows naive implementations or ones
that only target CPUs, where asynchronous parallel execution
might not be productive.

## Motivating Examples

### Basic Overlap

Modern computers have many different execution units, some
which are fully general, like CPU cores, and others which 
are specialized.  For example, Intel's latest server CPU
(codename: Sapphire Rapids) has at least three different
on-chip accelerators, including the Data Streaming Accelerator
(DSA), which is capable of executing data parallel operations
fill, copy and compare faster than and asynchronous relative
to the CPU cores.  While current Fortran compilers could
utilize the DSA for `DO CONCURRENT`, the current semantics
provide no mechanism for the programmer to encourage such
a region to be executed on the DSA while returning control
immediately to allow the CPU to execute the following code.

https://www.intel.com/content/www/us/en/developer/articles/technical/scalable-io-between-accelerators-host-processors.html

Similar compute engines to DSA exist for the capability
required by Fortran's `MATMUL`, for example.  Processors
from Apple, Intel and NVIDIA have dedicated matrix units,
which are separate silicon from the rest of the process
and may be capable of executing independently, i.e.
asynchronously.

Even without special processing engines, all modern CPUs,
including ones found in cheap cell phones, contain multiple
cores.  While Fortran permits programs to utilize parallelism
across cores using coarrays and `DO CONCURRENT`, the former
does not support shared-memory and thus requires unnecessary
copies of data between images when cores can access the same
data coherently, and the latter is limited to highly structured
data parallelism and prohibits impure procedures.  There are
uncountable examples of less structured models for multicore
parallelism, including OS threads, that can be expressed in 
terms of asynchronous tasks.

Finally, and of great relevance to the Fortran community,
are the use of accelerators or coprocessors, which are
attached to CPUs via a high-bandwidth interconnect, and which
support a large portion of Fortran programming language.
Recently, both NVIDIA and Intel have begun to support
`DO CONCURRENT` on GPUs, but the current semantics do not
permit the programmer to describe the asynchronous nature
of GPU computing, which is default in native APIs like
OpenCL, CUDA, HIP and SYCL (or Intel's Data Parallel C++).
Fortran programs that use OpenMP or OpenACC can achieve
asynchronous behavior in `DO CONCURRENT`, but not without
stepping outside of the standard.

### Quantum chemical many-body theory

Quantum chemical many-body theory requires the computation
of a large number of terms (dozens to hundreds), many of which
are independent of one another.  In a Fortran implementation
where `DO CONCURRENT` and intrinsics like `MATMUL` are capable
of being executed asynchronously relative to the rest of the
program, the availability of an asynchronous or task-like
mechanism allows a more efficient implementation of this than
is otherwise possible.

Shown below is the computational graph associated with one
version of the populare CCSD method.  It has been implemented
using GPU parallelism, and asynchronous execution of 
data parallel kernels and matrix multiplication operations
enables better utilization of the GPU and overlap of 
computation and data movement, leading to a 2.5x speedup
relative to the synchronous GPU implementation.

<img width="655" alt="Screenshot 2023-05-05 at 15 50 53" src="https://user-images.githubusercontent.com/406118/236462123-a13e2476-7371-4d56-9a11-dcb96c85c5d6.png">

https://pubs.acs.org/doi/abs/10.1021/ct100584w
https://dl.acm.org/doi/10.1145/2425676.2425687






