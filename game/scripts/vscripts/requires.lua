for _,file in pairs({
    
    'app/core/boot',
    'app/core/event',
    
    'app/maps/'..GetMapName(),
    
    'app/utils/debug',
    'app/utils/helpers',
    
    'vendor/inspect',
    
    'settings',
    
}) do require(file) end
