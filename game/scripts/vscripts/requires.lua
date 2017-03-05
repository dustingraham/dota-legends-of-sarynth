for _,file in pairs({
    
    'app/core/boot',
    
    'app/utils/debug',
    'app/utils/helpers',
    
    'vendor/inspect',
    
    'settings',
    
}) do require(file) end
