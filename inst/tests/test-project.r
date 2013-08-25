context("project method")

test_that("time dimension is dealt with properly",{
    data(species_params_gears)
    data(inter)
    params <- MizerParams(species_params_gears, inter)

    # Effort is a single numeric
    # If dt and t_save don't match
    expect_error(project(params,effort=1,t_save=3,dt=2, t_max = 10))
    # If t_max and t_save don't match
    expect_error( project(params,effort=1,t_max=7,dt=2))

    t_max <- 5
    t_save <- 1
    dt <- 0.1
    sim <- project(params,t_max=t_max,t_save=t_save, dt = dt, effort = 1)
    expect_that(dim(sim@effort)[1], equals(length(seq(from = t_save, to = t_max, by = t_save))))
    expect_that(dim(sim@n)[1], equals(1 + (length(seq(from = t_save, to = t_max, by = t_save)))))
    expect_that(dimnames(sim@effort)[[1]], is_identical_to(as.character(seq(from = t_save, to = t_max, by = t_save))))
    expect_that(dimnames(sim@n)[[1]], is_identical_to(as.character(seq(from = 0, to = t_max, by = t_save))))
    dt <- 0.5
    t_save <- 2
    sim <- project(params,t_max=t_max,t_save=t_save, dt=dt, effort = 1)
    expect_that(dim(sim@effort)[1], equals(length(seq(from = t_save, to = t_max, by = t_save))))
    expect_that(dim(sim@n)[1], equals(1 + (length(seq(from = t_save, to = t_max, by = t_save)))))
    expect_that(dimnames(sim@effort)[[1]], is_identical_to(as.character(seq(from = t_save, to = t_max, by = t_save))))
    expect_that(dimnames(sim@n)[[1]], is_identical_to(as.character(seq(from = 0, to = t_max, by = t_save))))
    t_save <- 0.5
    dt <- 0.5
    sim <- project(params,t_max=t_max,t_save=t_save, dt=dt, effort = 1)
    expect_that(dim(sim@effort)[1], equals(t_max/t_save - 1))
    expect_that(dim(sim@n)[1], equals(1 + (t_max/t_save - 1)))
    expect_that(dimnames(sim@effort)[[1]], is_identical_to(as.character(seq(from = 1, to = t_max, by = t_save))))
    expect_that(dimnames(sim@n)[[1]], is_identical_to(as.character(seq(from = t_save, to = t_max, by = t_save))))

    # Effort is an effort vector
    effort <- c(industrial = 1, pelagic = 0.5, beam_trawl = 0.3, otter_trawl = 0)
    # If dt and t_save don't match
    expect_error(project(params,effort=effort,t_save=3,dt=2))
    # If t_max and t_save don't match
    expect_error( project(params,effort=effort,t_max=7,dt=2))
    t_max <- 5
    t_save <- 2
    sim <- project(params,t_max=t_max,t_save=t_save, effort = effort)
    expect_that(dim(sim@effort)[1], equals(length(seq(from = t_save, to = t_max, by = t_save))))
    expect_that(dim(sim@n)[1], equals(1 + (length(seq(from = t_save, to = t_max, by = t_save)))))
    expect_that(dimnames(sim@effort)[[1]], is_identical_to(as.character(seq(from = t_save, to = t_max, by = t_save))))
    expect_that(dimnames(sim@n)[[1]], is_identical_to(as.character(seq(from = 0, to = t_max, by = t_save))))
    dt <- 0.5
    sim <- project(params,t_max=t_max,t_save=t_save, dt=dt, effort = effort)
    expect_that(dim(sim@effort)[1], equals(length(seq(from = t_save, to = t_max, by = t_save))))
    expect_that(dim(sim@n)[1], equals(1 + (length(seq(from = t_save, to = t_max, by = t_save)))))
    expect_that(dimnames(sim@effort)[[1]], is_identical_to(as.character(seq(from = t_save, to = t_max, by = t_save))))
    expect_that(dimnames(sim@n)[[1]], is_identical_to(as.character(seq(from = 0, to = t_max, by = t_save))))
    t_save <- 0.5
    sim <- project(params,t_max=t_max,t_save=t_save, dt=dt, effort = effort)
    expect_that(dim(sim@effort)[1], equals(length(seq(from = 1, to = t_max, by = t_save))))
    expect_that(dim(sim@n)[1], equals(1 + (length(seq(from = 1, to = t_max, by = t_save)))))
    expect_that(dimnames(sim@effort)[[1]], is_identical_to(as.character(seq(from = 1, to = t_max, by = t_save))))
    expect_that(dimnames(sim@n)[[1]], is_identical_to(as.character(seq(from = t_save, to = t_max, by = t_save))))

    # Effort is an array
    t_max <- 5
    # time step = 1
    effort <- array(NA, dim = c(t_max, 4), dimnames=list(time = seq(from = 1, to = t_max, by = 1), gear = c("industrial","pelagic","otter_trawl","beam_trawl")))
    effort[,1] <- seq(from=0, to = 1, length = nrow(effort))
    effort[,2] <- 0.5
    effort[,3] <- seq(from=1, to = 0.5, length = nrow(effort))
    effort[,4] <- 0

    dt <- 0.1
    t_save <- 1
    sim <- project(params, t_save=t_save, dt=dt, effort = effort)
    expect_that(dim(sim@effort)[1], equals(t_max / t_save))
    expect_that(dimnames(sim@effort)[[1]], is_identical_to(as.character(seq(from = t_save, to = t_max, by = t_save))))

    dt <- 0.2
    t_save <- 2
    sim <- project(params, t_save=t_save, dt=dt, effort = effort)

    expect_that(dim(sim@effort)[1], equals(length(seq(from = t_save, to = t_max, by = t_save))))
    expect_that(dimnames(sim@effort)[[1]], is_identical_to(as.character(seq(from = t_save, to = t_max, by = t_save))))

    # Dimnames of time not start at 1
    t_max <- 5
    start_year <- 1980
    time_step <- 1
    end_year <- start_year + t_max - 1
    effort <- array(NA, dim = c(t_max, 4), dimnames=list(time = seq(from = start_year, to = end_year, by = time_step), gear = c("industrial","pelagic","otter_trawl","beam_trawl")))
    effort[,1] <- seq(from=0, to = 1, length = nrow(effort))
    effort[,2] <- 0.5
    effort[,3] <- seq(from=1, to = 0.5, length = nrow(effort))
    effort[,4] <- 0

    dt <- 0.1
    t_save <- 1
    sim <- project(params, t_save=t_save, dt=dt, effort = effort)
    expect_that(dim(sim@effort)[1], equals(length(seq(from = start_year, to = end_year, by = t_save))))
    expect_that(dimnames(sim@effort)[[1]], is_identical_to(as.character(seq(from = start_year, to = end_year, by = t_save))))

    dt <- 0.1
    t_save <- 2
    sim <- project(params, t_save=t_save, dt=dt, effort = effort)
    expect_that(dim(sim@effort)[1], equals(length(seq(from = start_year+1, to = end_year, by = t_save))))
    expect_that(dimnames(sim@effort)[[1]], is_identical_to(as.character(seq(from = start_year+1, to = end_year, by = t_save))))

    dt <- 0.1
    t_save <- 0.5
    sim <- project(params, t_save=t_save, dt=dt, effort = effort)
    expect_that(dim(sim@effort)[1], equals(length(seq(from = start_year, to = end_year, by = t_save))))
    expect_that(dimnames(sim@effort)[[1]], is_identical_to(as.character(seq(from = start_year, to = end_year, by = t_save))))

    # Starting from 1980, effort every half year
    t_max <- 5
    start_year <- 1980
    time_step <- 0.5
    end_year <- start_year + t_max - 1
    time <- seq(from = start_year, to = end_year, by = time_step)
    effort <- array(NA, dim = c(length(time), 4), dimnames=list(time = time, gear = c("industrial","pelagic","otter_trawl","beam_trawl")))
    effort[,1] <- seq(from=0, to = 1, length = nrow(effort))
    effort[,2] <- 0.5
    effort[,3] <- seq(from=1, to = 0.5, length = nrow(effort))
    effort[,4] <- 0

    dt <- 0.1
    t_save <- 1
    sim <- project(params, t_save=t_save, dt=dt, effort = effort)
    expect_that(dim(sim@effort)[1], equals(length(seq(from = start_year, to = end_year, by = t_save))))
    expect_that(dimnames(sim@effort)[[1]], is_identical_to(as.character(seq(from = start_year, to = end_year, by = t_save))))

    dt <- 0.1
    t_save <- 2
    sim <- project(params, t_save=t_save, dt=dt, effort = effort)
    expect_that(dim(sim@effort)[1], equals(length(seq(from = start_year+1, to = end_year, by = t_save))))
    expect_that(dimnames(sim@effort)[[1]], is_identical_to(as.character(seq(from = start_year+1, to = end_year, by = t_save))))

    dt <- 0.1
    t_save <- 0.5
    sim <- project(params, t_save=t_save, dt=dt, effort = effort)
    expect_that(dim(sim@effort)[1], equals(length(seq(from = start_year, to = end_year, by = t_save))))
    expect_that(dimnames(sim@effort)[[1]], is_identical_to(as.character(seq(from = start_year, to = end_year, by = t_save))))

    dt <- 0.5
    t_save <- 0.5
    sim <- project(params, t_save=t_save, dt=dt, effort = effort)
    expect_that(dim(sim@effort)[1], equals(length(seq(from = start_year, to = end_year, by = t_save))))
    expect_that(dimnames(sim@effort)[[1]], is_identical_to(as.character(seq(from = start_year, to = end_year, by = t_save))))
})

test_that("Can pass in initial species",{
    data(species_params_gears)
    data(inter)
    params <- MizerParams(species_params_gears, inter)
    no_gear <- dim(params@catchability)[1]
    no_sp <- dim(params@catchability)[2]
    max_t_effort <- 10
    effort <- array(abs(rnorm(max_t_effort*no_gear)),dim=c(max_t_effort,no_gear))

    # No time dimnames - fail
    t_max <- 5
    start_year <- 1980
    time_step <- 0.5
    end_year <- start_year + t_max - 1
    time <- seq(from = start_year, to = end_year, by = time_step)
    effort <- array(NA, dim = c(length(time), 4), dimnames=list(NULL, gear = c("industrial","pelagic","otter_trawl","beam_trawl")))
    effort[,1] <- seq(from=0, to = 1, length = nrow(effort))
    effort[,2] <- 0.5
    effort[,3] <- seq(from=1, to = 0.5, length = nrow(effort))
    effort[,4] <- 0
    expect_that(project(params,effort=effort), throws_error())
})

test_that("get_initial_n is working properly",{
    data(species_params_gears)
    data(inter)
    params <- MizerParams(species_params_gears, inter)
    n <- get_initial_n(params)
    no_sp <- nrow(params@species_params)
    for(i in 1:no_sp){
        expect_that(all(n[i,params@w > params@species_params$w_inf[i]] == 0), is_true())
        expect_that(all(n[i,params@w < params@species_params$w_min[i]] == 0), is_true())
    }
    # Check slope of all species is the same
    slopes <- rep(NA, no_sp)
    for(i in 1:no_sp){
        n_idx <- which(n[i,] != 0)
        slopes[i] <- (log(n[i,min(n_idx)]) - log(n[i,max(n_idx)])) / (log(params@w[min(n_idx)]) - log(params@w[max(n_idx)]))
    }
    expect_that(slopes, equals(rep(slopes[1],no_sp)))
    # Check that slopes = slope0
})

test_that("w_min array reference is working OK",{
    data(species_params_gears)
    data(inter)
    species_params_gears$w_min <- 0.001
    species_params_gears$w_min[1] <- 1
    params <- MizerParams(species_params_gears, inter)
    sim <- project(params, effort=1, t_max=5)
    expect_that(all(sim@n[6,1,1:(sim@params@species_params$w_min_idx[1]-1)]==0),is_true())
})

test_that("Gear checking and sorting is OK",{
    # Set up trait based model for easy testing ground
    no_sp <- 10
    min_w_inf <- 10
    max_w_inf <- 1e5
    w_inf <- 10^seq(from=log10(min_w_inf), to = log10(max_w_inf), length=no_sp)
    knife_edges <- w_inf * 0.05
    industrial_gears <- w_inf <= 500
    other_gears <- w_inf > 500
    gear_names <- rep("Industrial", no_sp)
    gear_names[other_gears] <- "Other"
    params_gear <- set_trait_model(no_sp = no_sp, min_w_inf = min_w_inf, max_w_inf = max_w_inf, knife_edge_size = knife_edges, gear_names = gear_names)
	gear_names <- dimnames(params_gear@catchability)[[1]]
    # Single vector of effort
    sim <- project(params_gear, effort=0.3, t_max = 10)
    expect_that(all(sim@effort==0.3), is_true())
    expect_that(all(dimnames(sim@effort)$gear == gear_names), is_true()) # Also checks order of gear names in resulting effort matches catchability
    # Effort vector
    # Should give same result
    effort_vec <- c(Other = 1, Industrial = 0)
    effort_vec2 <- c(Industrial = 0, Other = 1)
    sim <- project(params_gear, effort = effort_vec, t_max = 10)
    sim2 <- project(params_gear, effort = effort_vec2, t_max = 10)
    expect_that(all(sim@effort[,"Industrial"] == 0), is_true())
    expect_that(all(sim@effort[,"Other"] == 1), is_true())
    expect_that(all(sim2@effort[,"Industrial"] == 0), is_true())
    expect_that(all(sim2@effort[,"Other"] == 1), is_true())
    expect_that(all(dimnames(sim@effort)$gear == gear_names), is_true()) 
    expect_that(all(dimnames(sim2@effort)$gear == gear_names), is_true()) 
    # Should fail - number of gears wrong
    effort_vec3 <- c(Industrial = 0, Other = 1, Dummy = 0.5)
    expect_that(project(params_gear, effort = effort_vec3, t_max = 10), throws_error())
    effort_vec4 <- c(Industrial = 0) # Is OK because length is 1
    expect_that(project(params_gear, effort = effort_vec4, t_max = 10) , throws_error())
    # Should fail - names of gears wrong
    effort_vec5 <- c(Industrial = 0, Dummy = 1)
    expect_that(project(params_gear, effort = effort_vec5, t_max = 10), throws_error())
    # Array effort
    t_steps <- 10
    effort1 <- array(1,dim=c(t_steps,2))
    expect_that(project(params_gear, effort = effort1), throws_error())
    # Different order - should give same result
    effort2 <- array(rep(c(1,0), each = t_steps),dim=c(t_steps,2), dimnames=list(time = 1:t_steps,gear = c("Other","Industrial")))
    effort3 <- array(rep(c(0,1), each = t_steps),dim=c(t_steps,2), dimnames=list(time = 1:t_steps,gear = c("Industrial","Other")))
    sim2 <- project(params_gear, effort=effort2)
    sim3 <- project(params_gear, effort=effort3)
    expect_that(sim2, is_identical_to(sim3))
    # These should all fail - gears incorrectly specified
    effort4 <- array(rep(c(0,1,0.5), each = t_steps),dim=c(t_steps,3), dimnames=list(time = 1:t_steps,gear = c("Industrial","Other","Dummy")))
    effort5 <- array(rep(c(0,1), each = t_steps),dim=c(t_steps,2), dimnames=list(time = 1:t_steps,gear = c("Industrial","Dummy")))
    effort6 <- array(rep(c(1), each = t_steps),dim=c(t_steps,1), dimnames=list(time = 1:t_steps,gear = c("Industrial")))
    expect_that(project(params_gear, effort = effort4), throws_error())
    expect_that(project(params_gear, effort = effort5), throws_error())
    expect_that(project(params_gear, effort = effort6), throws_error())
})


