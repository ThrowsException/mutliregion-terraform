import fastify from 'fastify';

let server = fastify();

server.get('/', async (request, reply) => {
  return reply.send({ region: process.env.REGION });
});
server.get('/echo', async (request, reply) => {
  return reply.send({ region: process.env.REGION });
});

server.listen({ host: '0.0.0.0', port: 3000 });
