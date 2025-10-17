<template>
  <div class="ele-body">
    <el-card shadow="never">
      <!-- 搜索表单 -->
      <el-form
        :model="where"
        label-width="77px"
        class="ele-form-search"
        @keyup.enter.native="reload"
        @submit.native.prevent>
        <el-row :gutter="15">
    
          <el-col :lg="6" :md="12">
            <el-form-item label="案例名称:">
              <el-input
                clearable
                v-model="where.name"
                placeholder="请输入案例名称"/>
            </el-form-item>
          </el-col>
          <!-- 类型下拉单选 -->
          <el-col :lg="6" :md="12">
            <el-form-item label="类型:">
              <el-select
                clearable
                v-model="where.type"
                placeholder="请选择类型"
                class="ele-fluid">
                <el-option label="全部" value=""/>
                <el-option label="京东" :value="1"/>
                <el-option label="淘宝" :value="2"/>
                <el-option label="拼多多" :value="3"/>
                <el-option label="唯品会" :value="4"/>
              </el-select>
            </el-form-item>
          </el-col>
          <!-- 是否VIP下拉单选 -->
          <el-col :lg="6" :md="12">
            <el-form-item label="是否VIP:">
              <el-select
                clearable
                v-model="where.isVip"
                placeholder="请选择是否VIP"
                class="ele-fluid">
                <el-option label="全部" value=""/>
                <el-option label="是" :value="1"/>
                <el-option label="否" :value="2"/>
              </el-select>
            </el-form-item>
          </el-col>
          <!-- 状态下拉单选 -->
          <el-col :lg="6" :md="12">
            <el-form-item label="状态:">
              <el-select
                clearable
                v-model="where.status"
                placeholder="请选择状态"
                class="ele-fluid">
                <el-option label="全部" value=""/>
                <el-option label="正常" :value="1"/>
                <el-option label="停用" :value="2"/>
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :lg="6" :md="12">
            <div class="ele-form-actions">
              <el-button
                type="primary"
                icon="el-icon-search"
                class="ele-btn-icon"
                @click="reload">查询
              </el-button>
              <el-button @click="reset">重置</el-button>
            </div>
          </el-col>
        </el-row>
      </el-form>
      <!-- 数据表格 -->
      <ele-pro-table
        ref="table"
        :where="where"
        :datasource="url"
        :columns="columns"
        :selection.sync="selection"
        height="calc(100vh - 315px)">
        <!-- 表头工具栏 -->
        <template slot="toolbar">
          <el-button
            size="small"
            type="primary"
            icon="el-icon-plus"
            class="ele-btn-icon"
            @click="openEdit(null)"
            v-if="permission.includes('sys:example:add')">添加
          </el-button>
          <el-button
            size="small"
            type="danger"
            icon="el-icon-delete"
            class="ele-btn-icon"
            @click="removeBatch"
            v-if="permission.includes('sys:example:dall')">删除
          </el-button>
        </template>
        <!-- 操作列 -->
        <template slot="action" slot-scope="{row}">
          <el-link
            type="primary"
            :underline="false"
            icon="el-icon-edit"
            @click="openEdit(row)"
            v-if="permission.includes('sys:example:edit')">修改
          </el-link>
          <el-popconfirm
            class="ele-action"
            title="确定要删除此演示案例一吗？"
            @confirm="remove(row)">
            <el-link
              type="danger"
              slot="reference"
              :underline="false"
              icon="el-icon-delete"
              v-if="permission.includes('sys:example:delete')">删除
            </el-link>
          </el-popconfirm>
        </template>
        <!-- 头像列 -->
        <template slot="avatar" slot-scope="{row}">
          <el-avatar shape="square" :size="25" :src="row.avatar"/>
        </template>
        <!-- 使类型列 -->
        <template slot="type" slot-scope="{row}">
          <el-tag v-if="row.type === 1" type="" size="small">京东</el-tag>
          <el-tag v-if="row.type === 2" type="success" size="small">淘宝</el-tag>
          <el-tag v-if="row.type === 3" type="warning" size="small">拼多多</el-tag>
          <el-tag v-if="row.type === 4" type="danger" size="small">唯品会</el-tag>
        </template>
        <!-- 是否VIP列 -->
        <template slot="isVip" slot-scope="{row}">
          <el-switch
            v-model="row.isVip"
            @change="editIsVip(row)"
            :active-value="1"
            :inactive-value="2"/>
        </template>
        <!-- 状态列 -->
        <template slot="status" slot-scope="{row}">
          <el-switch
            v-model="row.status"
            @change="editStatus(row)"
            :active-value="1"
            :inactive-value="2"/>
        </template>
      </ele-pro-table>
    </el-card>
    <!-- 编辑弹窗 -->
    <example-edit
      :data="current"
      :visible.sync="showEdit"
      @done="reload"/>
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import ExampleEdit from './example-edit';

export default {
  name: 'ExamExample',
  components: {ExampleEdit},
  computed: {
    ...mapGetters(["permission"]),
  },
  data() {
    return {
      // 表格数据接口
      url: '/example/index',
      // 表格列配置
      columns: [
        {
          columnKey: 'selection',
          type: 'selection',
          width: 45,
          align: 'center',
          fixed: "left"
        },
        {
          prop: 'id',
          label: 'ID',
          width: 60,
          align: 'center',
          showOverflowTooltip: true,
          fixed: "left"
        },
        {
          columnKey: 'avatar',
          label: '头像',
          align: 'center',
          showOverflowTooltip: true,
          minWidth: 100,
          slot: 'avatar'
        },
        {
          prop: 'name',
          label: '案例名称',
          showOverflowTooltip: true,
          minWidth: 100,
          align: 'center'
        },
        {
          prop: 'type',
          label: '类型',
          align: 'center',
          showOverflowTooltip: true,
          minWidth: 100,
          slot: 'type',
        },
        {
          prop: 'isVip',
          label: '是否VIP',
          align: 'center',
          showOverflowTooltip: true,
          minWidth: 100,
          slot: 'isVip',
        },
        {
          prop: 'planTime',
          label: '计划时间',
          sortable: 'custom',
          showOverflowTooltip: true,
          minWidth: 160,
          align: 'center',
          formatter: (row, column, cellValue) => {
            return this.$util.toDateString(cellValue);
          }
        },
        {
          prop: 'status',
          label: '状态',
          align: 'center',
          showOverflowTooltip: true,
          minWidth: 100,
          slot: 'status',
        },
        {
          prop: 'sort',
          label: '显示顺序',
          showOverflowTooltip: true,
          minWidth: 100,
          align: 'center'
        },
        {
          prop: 'note',
          label: '备注',
          showOverflowTooltip: true,
          minWidth: 100,
          align: 'center'
        },
        {
          prop: 'createTime',
          label: '创建时间',
          sortable: 'custom',
          showOverflowTooltip: true,
          minWidth: 160,
          align: 'center',
          formatter: (row, column, cellValue) => {
            return this.$util.toDateString(cellValue);
          }
        },
        {
          prop: 'updateTime',
          label: '更新时间',
          sortable: 'custom',
          showOverflowTooltip: true,
          minWidth: 160,
          align: 'center',
          formatter: (row, column, cellValue) => {
            return this.$util.toDateString(cellValue);
          }
        },
        {
          columnKey: 'action',
          label: '操作',
          width: 150,
          align: 'center',
          resizable: false,
          slot: 'action',
          fixed: "right"
        }
      ],
      // 表格搜索条件
      where: {},
      // 表格选中数据
      selection: [],
      // 当前编辑数据
      current: null,
      // 是否显示编辑弹窗
      showEdit: false,
    };
  },
  methods: {
    /* 刷新表格 */
    reload() {
      this.$refs.table.reload({where: this.where});
    },
    /* 重置搜索 */
    reset() {
      this.where = {};
      this.reload();
    },
    /* 显示编辑 */
    openEdit(row) {
      this.current = row;
      this.showEdit = true;
    },
    /* 删除 */
    remove(row) {
      const loading = this.$loading({lock: true});
      this.$http.delete('/example/delete', {id: row.id}).then(res => {
        loading.close();
        if (res.data.code === 0) {
          this.$message.success(res.data.msg);
          this.reload();
        } else {
          this.$message.error(res.data.msg);
        }
      }).catch(e => {
        loading.close();
        this.$message.error(e.message);
      });
    },
    /* 批量删除 */
    removeBatch() {
      if (!this.selection.length) {
        this.$message.error('请至少选择一条数据');
        return;
      }
      this.$confirm('确定要删除选中的演示案例一吗?', '提示', {
        type: 'warning'
      }).then(() => {
        const loading = this.$loading({lock: true});
        this.$http.delete('/example/delete', {id: this.selection.map(d => d.id)}).then(res => {
          loading.close();
          if (res.data.code === 0) {
            this.$message.success(res.data.msg);
            this.reload();
          } else {
            this.$message.error(res.data.msg);
          }
        }).catch(e => {
          loading.close();
          this.$message.error(e.message);
        });
      }).catch(() => {
      });
    },
    /* 更改状态 */
    editIsVip(row) {
      const loading = this.$loading({lock: true});
      let params = Object.assign({
        "id": row.id,
        "isVip": row.isVip
      })
      this.$http.put('/example/setIsVip', params).then(res => {
        loading.close();
        if (res.data.code === 0) {
          this.$message.success(res.data.msg);
        } else {
          row.status = !row.status ? 1 : 2;
          this.$message.error(res.data.msg);
        }
      }).catch(e => {
        loading.close();
        this.$message.error(e.message);
      });
    },
    /* 更改状态 */
    editStatus(row) {
      const loading = this.$loading({lock: true});
      let params = Object.assign({
        "id": row.id,
        "status": row.status
      })
      this.$http.put('/example/setStatus', params).then(res => {
        loading.close();
        if (res.data.code === 0) {
          this.$message.success(res.data.msg);
        } else {
          row.status = !row.status ? 1 : 2;
          this.$message.error(res.data.msg);
        }
      }).catch(e => {
        loading.close();
        this.$message.error(e.message);
      });
    },
  }
}
</script>

<style scoped>
</style>
