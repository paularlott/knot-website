---
title: Troubleshooting
weight: 130
---

Common issues and solutions organized by topic.

---

## Server Issues

### Server Won't Start

**Symptom**: Server exits immediately or fails to start.

**Common Causes**:
- Missing or invalid configuration file
- Port already in use
- Database connection failure
- Invalid encryption key

**Solutions**:
1. Check configuration file syntax
2. Verify ports are available
3. Check database connectivity (MySQL/Redis)
4. Regenerate encryption key if needed: `knot genkey`

### Database Connection Errors

**Symptom**: Server logs show database connection failures.

**Solutions**:
- Verify database credentials in configuration
- Check database server is running and accessible
- For MySQL: Ensure database exists and user has permissions
- For Redis / Valkey: Verify host and port are correct
- Test connection manually before starting knot

---

## Space Issues

### Space Won't Start

**Symptom**: Space stays in "Starting" state or fails to start.

**Common Causes**:
- Insufficient resources in cluster
- Volume creation failure
- Image pull errors
- Invalid template configuration

**Solutions**:
1. Check space logs in the web interface
2. For Nomad: Check Nomad UI for allocation errors
3. Verify template variables are correctly set
4. Ensure container image is accessible
5. Check volume storage is available

### Space Stops Unexpectedly

**Symptom**: Running space stops without user action.

**Common Causes**:
- Maximum uptime reached
- Outside scheduled hours
- Resource limits exceeded
- Container crashed

**Solutions**:
- Check template maximum uptime setting
- Verify schedule allows current time
- Review space logs for crash information
- Check resource quotas

### Cannot Connect to Space

**Symptom**: Space is running but terminal/SSH won't connect.

**Solutions**:
1. Verify space status is "Running"
2. Check knot agent is running inside container
3. For SSH: Ensure SSH key is added to profile
4. Test with web terminal first
5. Check firewall rules and network connectivity

---

## Authentication Issues

### Cannot Login

**Symptom**: Login fails with correct credentials.

**Solutions**:
- Verify username and password are correct
- Check if 2FA is enabled and code is valid
- Clear browser cache and cookies
- Check server logs for authentication errors
- Verify user account is not locked

### Token Expired

**Symptom**: API calls fail with authentication error.

**Solutions**:
- Tokens expire after 2 weeks of inactivity
- Generate new token from web interface
- For CLI: Run `knot connect` again

---

## Network Issues

### DNS Resolution Fails

**Symptom**: Cannot access spaces via wildcard domain.

**Solutions**:
1. Verify DNS configuration
2. Check DNS server is running (if using built-in)
3. Verify DNS forwarding is configured correctly
4. Restart DNS resolver service

### Port Forwarding Not Working

**Symptom**: Cannot access forwarded ports.

**Solutions**:
- Verify knot client is connected: `knot connect`
- Check port is advertised in space
- Ensure local port is not already in use
- Try different local port
- Check firewall rules

### Tunnel Connection Fails

**Symptom**: Cannot create or access tunnels.

**Solutions**:
- Verify tunnel server is configured in knot.toml
- Check wildcard DNS points to tunnel port
- Ensure tunnel name is unique
- Review tunnel server logs

---

## Template Issues

### Template Variables Not Working

**Symptom**: Variables show as literal text instead of values.

**Solutions**:
- Check variable syntax: `${{ .variable.name }}`
- Verify variable is defined (system, user, or custom)
- For custom variables: Ensure defined in template
- Check for typos in variable names

### Volume Creation Fails

**Symptom**: Space fails to start due to volume errors.

**Solutions**:
- For Nomad: Verify CSI driver is installed and working
- Check volume definition syntax
- Ensure storage capacity is available
- Verify volume plugin_id is correct
- Check CSI controller and node plugins are running

---

## Performance Issues

### Slow Web Interface

**Solutions**:
- Check server resource usage (CPU, memory)
- Verify database performance
- For cluster mode: Check network latency between nodes
- Review server logs for errors
- Consider scaling resources

### High Latency to Spaces

**Solutions**:
- Use cluster mode with servers near users
- Consider leaf mode for local execution
- Check network path to server
- Verify server is not overloaded

---

## Cluster Issues

### Nodes Not Connecting

**Symptom**: Cluster nodes don't see each other.

**Solutions**:
- Verify cluster key matches on all nodes
- Check advertise_addr is accessible from other nodes
- Ensure all nodes list each other in peers
- Check firewall allows traffic between nodes
- Review cluster logs on all nodes

### Data Not Synchronizing

**Symptom**: Changes on one node not visible on others.

**Solutions**:
- Check cluster status in web interface
- Verify network connectivity between nodes
- Review synchronization logs
- Ensure clocks are synchronized (NTP)

---

## Common Error Messages

**"Space quota exceeded"**
User has reached maximum number of spaces allowed. Delete stopped spaces or contact admin to increase quota.

**"Compute units exceeded"**
User has insufficient compute units to start space. Stop other spaces or contact admin to increase quota.

**"Template not found"**
Template may be inactive or user lacks group membership. Verify template exists and user has access.

**"Invalid token"**
API token expired or invalid. Generate new token or run `knot connect` again.

---

## Getting Help

If you cannot resolve an issue:

1. Check server logs for detailed error messages
2. Review space logs in web interface
3. For Nomad: Check Nomad allocation logs
4. Enable debug logging: Set `log.level = "debug"` in configuration
5. Check GitHub issues: https://github.com/paularlott/knot/issues

---

## Debug Logging

Enable detailed logging to troubleshoot issues:

```toml {filename=knot.toml}
[log]
level = "debug"
```

Restart the server to apply changes.
