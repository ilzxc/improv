Envelope = () ->
    @currentValue = 0
    @startTime = 0
    @endTime = 0
    @duration = 0
    @exponent = 1
    @reverse = false
    @busy = false
    @isRest = false

    @start = (duration, exponent, reverse, restLiklihood=0.15, restDuration=duration) ->
        @busy = true
        @startTime = (new Date()).getTime() / 1000
        @endTime = @startTime + duration
        @exponent = if exponent < 0 then 1.0 / (-exponent) else 1.0 + exponent
        @reverse = reverse
        if Math.random() < restLiklihood 
            @isRest = true
            @duration = restDuration
        else 
            @isRest = false
            @duration = duration
        return

    @update = (currentTime) ->
        if currentTime == null
            currentTime = (new Date()).getTime() / 1000
        t = (currentTime - @startTime) / @duration
        if t < 1
            @currentValue = Math.pow t, @exponent
        else
            @currentValue = 1
            @busy = false
        if @reverse then @currentValue = 1.0 - @currentValue
        if @isRest then 1 else @currentValue
    this

module.exports = { Envelope }
