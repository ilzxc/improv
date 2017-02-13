Envelope = () ->
    @currentValue = 0
    @startTime = 0
    @endTime = 0
    @duration = 0
    @exponent = 1
    @flip = false
    @reverse = false
    @busy = false

    @start = (duration, exponent, reverse) ->
        @busy = true
        @startTime = (new Date()).getTime() / 1000
        @endTime = @startTime + duration
        @duration = duration
        @flip = if exponent < 0 then true else false
        @exponent = if exponent < 0 then 1.0 / (-exponent) else 1.0 + exponent
        @reverse = reverse
        return

    @update = (currentTime) ->
        t = (currentTime - @startTime) / @duration
        console.log 't', t
        if t < 1
            @currentValue = Math.pow t, @exponent
        else
            @currentValue = 1
            @busy = false
        if @reverse
            @currentValue = 1.0 - @currentValue
        @currentValue
    return this

module.exports = { Envelope }
